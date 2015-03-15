//
//  TKLViewController.m
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AFNetworking.h"

#import "TKLBus.h"
#import "TKLViewController.h"
#import "TKLBusAnnotation.h"


@implementation TKLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add location button
    MKUserTrackingBarButtonItem *locationButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem = locationButton;

    NSMutableArray *buttonsArray = [[NSMutableArray alloc] initWithArray:self.toolBar.items];
    [buttonsArray addObject:locationButton];
    [self.toolBar setItems:buttonsArray];

    _buses = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;

    // Tampere
    zoomLocation.latitude = 61.489987;
    zoomLocation.longitude= 23.780417;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 13000, 13000);
    [_mapView setRegion:viewRegion animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    [self fetchAndRenderBusPositions];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                repeats:YES];
    
}

-(void)appWillResignActive:(NSNotification*)note
{
    
}
-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}

- (void)animateLoader {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
}

- (void)timerFired:(NSTimer*)timer {
    [self fetchAndRenderBusPositions];
}

- (void)fetchAndRenderBusPositions {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:@"http://lissu-api-backup.herokuapp.com" parameters:nil
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self onDataSuccess:responseObject];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)onDataSuccess:(id)jsonResponse {
    NSDictionary *vehicles = jsonResponse[@"vehicles"];
    
    for (NSDictionary *vehicle in vehicles) {
        NSLog(@"JSON: %@", vehicle[@"line"]);
        
        NSString *busId = vehicle[@"id"];
        NSString *busLine = vehicle[@"line"];
        NSNumber *latitude = vehicle[@"latitude"];
        NSNumber *longitude = vehicle[@"longitude"];
        NSNumber *bearing = vehicle[@"rotation"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
    
        TKLBus *bus = [self findBus:busId];
        if (bus == nil) {
            [self createBusAnnotation:busId busLine:busLine busCoordinate:coordinate bearing:bearing];
        } else {
            [self moveBusAnnotation:bus coordinate:coordinate];
        }
    }
    
    // TODO: remove left overs

}

- (void)createBusAnnotation:(NSString*)busId busLine:(NSString*)busLine busCoordinate:(CLLocationCoordinate2D)busCoordinate bearing:(NSNumber*)bearing {
    NSLog(@"createBusAnnotation");
    TKLBus *bus = [[TKLBus alloc] init];
    bus.identifier = busId;
    bus.line = busLine;
    bus.coordinate = busCoordinate;
    bus.bearing = bearing;
    
    TKLBusAnnotation *annotation = [[TKLBusAnnotation alloc] initWithBus:bus];
    [_mapView addAnnotation:annotation];
    
    bus.annotation = annotation;
    [_buses addObject:bus];
}

- (void)moveBusAnnotation:(TKLBus*)bus coordinate:(CLLocationCoordinate2D)coordinate {
    /*
    [UIView animateWithDuration:0.5f
    animations:^(void){
        bus.annotation.coordinate = coordinate;
    }];
     */
    [bus.annotation setCoordinate:coordinate];

    // TODO: 
    // Get annotation view from annotation somehow
    // there's a subview which contains UIImageView
    // then set new transform for that view.
    
    NSLog(@"moveBusAnnotation");
}

- (TKLBus*)findBus:(NSString*)busId {
    for (TKLBus *bus in _buses) {
        if ([busId isEqualToString:bus.identifier]) {
            return bus;
        }
    }
    
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"bus";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        
        // Convert passed annotation to our custom annotation annotation
        TKLBusAnnotation *busAnnotation = (TKLBusAnnotation*) annotation;
        TKLBus *bus = busAnnotation.bus;
        BOOL isMoving = ![bus.bearing isEqual:@0];
        NSString *busIcon = (isMoving) ? @"bus-moving" : @"bus";
        UIImage *busIconImage = [UIImage imageNamed:busIcon];

        UIImageView *uiImageView = [[UIImageView alloc] initWithImage:busIconImage];
        uiImageView.transform = CGAffineTransformMakeRotation([bus.bearing floatValue]);
        [annotationView addSubview:uiImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.tag = 42;
        label.adjustsFontSizeToFitWidth = YES;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 1;
        label.clipsToBounds = YES;
        [label setFont:[UIFont systemFontOfSize:12]];
        [annotationView addSubview:label];
        
        annotationView.frame = label.frame;
    } else {
        annotationView.annotation = annotation;
    }
    
    UILabel *label = (UILabel *)[annotationView viewWithTag:42];
    label.text = annotation.title;
    
    return annotationView;
}

- (void)mapView:(MKMapView*)mapView regionWillChangeAnimated:(BOOL)animated {
    // Stop all animations when map is zoomed / panned
    NSLog(@"regionWillChangeAnimated");
    for (int i = 0; i < [mapView.annotations count]; i++) {
        id annotation = [mapView.annotations objectAtIndex:i];
        
        MKAnnotationView *annotationView = [mapView viewForAnnotation: annotation];
        if (annotationView != nil) {
            CALayer* layer = annotationView.layer;
            [layer removeAllAnimations];
        }
    }
}

@end

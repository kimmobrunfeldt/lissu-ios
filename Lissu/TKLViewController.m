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
    
    
    [self fetchAndRenderBusPositions];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                repeats:YES];
    
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
    
    // http://data.itsfactory.fi/siriaccess/vm/json
    [manager GET:@"http://data.itsfactory.fi/siriaccess/vm/json" parameters:nil
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self onDataSuccess:responseObject];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)onDataSuccess:(id)jsonResponse {
    NSDictionary *vehicles = jsonResponse[@"Siri"][@"ServiceDelivery"][@"VehicleMonitoringDelivery"][0][@"VehicleActivity"];
    
    for (NSDictionary *vehicle in vehicles) {
        NSLog(@"JSON: %@", vehicle[@"MonitoredVehicleJourney"][@"LineRef"][@"value"]);
        
        NSString *busId = vehicle[@"MonitoredVehicleJourney"][@"VehicleRef"][@"value"];
        NSString *busLine = vehicle[@"MonitoredVehicleJourney"][@"LineRef"][@"value"];
        NSNumber *latitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Latitude"];
        NSNumber *longitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Longitude"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
    
        TKLBus *bus = [self findBus:busId];
        if (bus == nil) {
            [self createBusAnnotation:busId busLine:busLine busCoordinate:coordinate];
        } else {
            [self moveBusAnnotation:bus coordinate:coordinate];
        }
    }

}

- (void)createBusAnnotation:(NSString*)busId busLine:(NSString*)busLine busCoordinate:(CLLocationCoordinate2D)busCoordinate {
    NSLog(@"createBusAnnotation");
    TKLBus *bus = [[TKLBus alloc] init];
    bus.identifier = busId;
    bus.line = busLine;
    bus.coordinate = busCoordinate;
    
    TKLBusAnnotation *annotation = [[TKLBusAnnotation alloc] initWithBus:bus];
    [_mapView addAnnotation:annotation];
    
    bus.annotation = annotation;
    [_buses addObject:bus];
}

- (void)moveBusAnnotation:(TKLBus*)bus coordinate:(CLLocationCoordinate2D)coordinate {
    [UIView animateWithDuration:0.5f
    animations:^(void){
        bus.annotation.coordinate = coordinate;
    }];
     
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
    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];

        label.textAlignment = NSTextAlignmentCenter;

        label.backgroundColor = [UIColor colorWithRed:114.0/255.0 green:163.0/255.0 blue:191.0/255.0 alpha:0.9];
        label.textColor = [UIColor whiteColor];
        label.tag = 42;
        label.adjustsFontSizeToFitWidth = YES;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 1;
        label.layer.cornerRadius = 13;
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

//
//  TKLViewController.m
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AFNetworking.h"

#import "TKLViewController.h"
#import "TKLBusAnnotation.h"


@interface TKLViewController ()

@end

@implementation TKLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add location button
    MKUserTrackingBarButtonItem *locationButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem = locationButton;

    NSMutableArray *buttonsArray = [[NSMutableArray alloc] initWithArray:self.toolBar.items];
    [buttonsArray addObject:locationButton];
    [self.toolBar setItems:buttonsArray];
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

- (void)timerFired:(NSTimer*)timer {
    [self fetchAndRenderBusPositions];
}

- (void)fetchAndRenderBusPositions {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
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
    
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    for (NSDictionary *vehicle in vehicles) {
        NSLog(@"JSON: %@", vehicle[@"MonitoredVehicleJourney"][@"LineRef"][@"value"]);
        
        NSString *busId = vehicle[@"MonitoredVehicleJourney"][@"VehicleRef"][@"value"];
        NSString *busLine = vehicle[@"MonitoredVehicleJourney"][@"LineRef"][@"value"];
        NSNumber *latitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Latitude"];
        NSNumber *longitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Longitude"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        
        TKLBusAnnotation *point = [[TKLBusAnnotation alloc] initWithBusLine:busId busLine:busLine coordinate:coordinate];
        [_mapView addAnnotation:point];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"reuseid";
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

@end

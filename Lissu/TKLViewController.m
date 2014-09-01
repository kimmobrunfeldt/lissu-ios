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


@interface TKLViewController ()

@end

@implementation TKLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 61.489987;
    zoomLocation.longitude= 23.780417;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10000, 10000);
    
    [_mapView setRegion:viewRegion animated:YES];
    
    [self fetchAndRenderBusPositions];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
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
        
        NSNumber *latitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Latitude"];
        NSNumber *longitude = vehicle[@"MonitoredVehicleJourney"][@"VehicleLocation"][@"Longitude"];
        NSString *busLine = vehicle[@"MonitoredVehicleJourney"][@"LineRef"][@"value"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coordinate;
        point.title = busLine;
        point.subtitle = @"Test";
        
        [_mapView addAnnotation:point];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

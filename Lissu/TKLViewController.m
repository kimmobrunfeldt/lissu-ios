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

    NSMutableArray *buttonsArray = [[NSMutableArray alloc]initWithArray:self.toolBar.items];
    [buttonsArray addObject:locationButton];
    [self.toolBar setItems:buttonsArray];
    
//   [self.mapView setDelegate:(UITabBarController *) self];
}

- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 61.489987;
    zoomLocation.longitude= 23.780417;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 13000, 13000);
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
        
        TKLBusAnnotation *point = [[TKLBusAnnotation alloc] initWithBusLine:busLine coordinate:coordinate];        
        [_mapView addAnnotation:point];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSLog(@"mapView called");
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"reuseid";
    MKAnnotationView *av = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (av == nil)
    {
        av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        lbl.backgroundColor = [UIColor blackColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.alpha = 0.5;
        lbl.tag = 42;
        [av addSubview:lbl];
        
        //Following lets the callout still work if you tap on the label...
        av.canShowCallout = YES;
        av.frame = lbl.frame;
    }
    else
    {
        av.annotation = annotation;
    }
    
    UILabel *lbl = (UILabel *)[av viewWithTag:42];
    lbl.text = annotation.title;
    
    return av;
}

@end

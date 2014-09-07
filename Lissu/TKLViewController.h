//
//  TKLViewController.h
//  Lissu
//
//  Created by Kimmo Brunfeldt on 2.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface TKLViewController : UIViewController <MKMapViewDelegate>

- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation;
- (void)mapView:(MKMapView*)mapView regionWillChangeAnimated:(BOOL)animated;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong) NSTimer *timer;
@property (strong) NSMutableArray *buses;

@end

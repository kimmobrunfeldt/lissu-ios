//
//  TKLViewController.h
//  Lissu
//
//  Created by Kimmo Brunfeldt on 2.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface TKLViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSTimer *timer;

@end

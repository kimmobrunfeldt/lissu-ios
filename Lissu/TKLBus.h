//
//  Bus.h
//  
//
//  Created by Kimmo Brunfeldt on 6.9.2014.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "TKLBusAnnotation.h"

@interface TKLBus : NSObject 

// VehicleRef, e.g. @"TKL_267"
@property (strong) NSString *identifier;

// LineRef, e.g. @"13"
@property (strong) NSString *line;

// Bus' location
@property (nonatomic) CLLocationCoordinate2D coordinate;

// Bearing, in degrees, clockwise from True North, i.e., 0 is North and 90 is
// East. This can be the compass bearing, or the direction towards the next
// stop or intermediate location
@property (nonatomic) NSNumber *bearing;

// Reference to map annotation
@property (strong) TKLBusAnnotation *annotation;

@end

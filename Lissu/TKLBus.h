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

// Reference to map annotation
@property (strong) TKLBusAnnotation *annotation;

@end

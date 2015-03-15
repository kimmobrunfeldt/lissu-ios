//
//  TKLBusLocation.h
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class TKLBus;

@interface TKLBusAnnotation : NSObject <MKAnnotation>

@property (nonatomic) TKLBus *bus;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) NSNumber *bearing;

- (id)initWithBus:(TKLBus*)bus;

- (MKMapItem*)mapItem;

@end

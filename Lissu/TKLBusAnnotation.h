//
//  TKLBusLocation.h
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface TKLBusAnnotation : NSObject <MKAnnotation>

- (id)initWithBusLine:(NSString*)busId busLine:(NSString*)busLine coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end

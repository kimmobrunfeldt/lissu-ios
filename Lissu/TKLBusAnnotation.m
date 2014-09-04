//
//  TKLBusLocation.m
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import "TKLBusAnnotation.h"
#import <AddressBook/AddressBook.h>

@interface TKLBusAnnotation()

// VehicleRef, e.g. @"TKL_267"
@property (nonatomic, copy) NSString *busId;

// LineRef, e.g. @"13"
@property (nonatomic, copy) NSString *busLine;

// Variable named coordinate is reserved for internal use
@property (nonatomic, assign) CLLocationCoordinate2D busCoordinate;

@end

@implementation TKLBusAnnotation

- (id)initWithBusLine:(NSString*)busId busLine:(NSString*)busLine coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        self.busId = busId;
        self.busLine = busLine;
        self.busCoordinate = coordinate;
    }
    
    return self;
}

- (NSString *)title {
    return _busLine;
}

- (NSString *)subtitle {
    return @"";
}

- (CLLocationCoordinate2D)coordinate {
    return _busCoordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString *) kABPersonAddressStreetKey : @""};
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.busCoordinate addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end

//
//  TKLBusLocation.m
//  Lissu
//
//  Created by Kimmo Brunfeldt on 1.9.2014.
//  Copyright (c) 2014 Kimmo Brunfeldt. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "TKLBusAnnotation.h"
#import "TKLBus.h"


@implementation TKLBusAnnotation

- (id)initWithBus:(TKLBus*)bus {
    if ((self = [super init])) {
        _bus = bus;
    }
    
    return self;
}

- (NSString *)title {
    return _bus.line;
}

- (NSString *)subtitle {
    return @"";
}

- (void)setBearing:(NSNumber *)bearing {
    //UIImage *rotatedImage = [originalImage imageRotatedByDegrees:90.0];
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString *) kABPersonAddressStreetKey : @""};
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:_bus.coordinate addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end

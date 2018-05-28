//
//  GoogleServicesManager.h
//  Ego
//
//  Created by Mahmoud Amer on 9/16/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import <GoogleMaps/GMSGeocoder.h>

#import "ServiceManager.h"
#import "RidesServiceManager.h"


#define GMS_SERVICE_KEY @"AIzaSyBrKSj3YS_JxlU2dNKs9HvKcGvkzzQa6_M"
#define GMS_SHORTENURL_KEY @"AIzaSyBTBJQnDv4uF90MwkKA82sL6BRU0jmPFOA"

@interface GoogleServicesManager : NSObject

+(void)getRouteFrom:(CLLocationCoordinate2D)fromLocation to:(CLLocationCoordinate2D)toLocation :( void (^)(NSDictionary *))completion;

+(void)getAddressFromCoordinates:(float)latitude andLong:(float)longitude :( void (^)(NSDictionary *))completion;

+(void)getCoordinatesFromSharedString:(NSString *)shareString :( void (^)(NSArray *))completion;

@end

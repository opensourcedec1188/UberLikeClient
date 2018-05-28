//
//  RidesServiceManager.h
//  Ego
//
//  Created by MacBookPro on 4/25/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "ServiceManager.h"
#import "HelperClass.h"

#define BASE_URL @"https://www.procabnow.com/api/v0"

/* Ride Status */
#define RIDE_STATUS_INITIATED @"initiated"
#define RIDE_STATUS_ACCEPTED @"accepted"
#define RIDE_STATUS_NEARBY @"nearby"
#define RIDE_STATUS_ARRIVED @"arrived"
#define RIDE_STATUS_STARTED @"on-ride"
#define RIDE_STATUS_ENDED @"clearance"
#define RIDE_STATUS_FINISHED @"finished"


#define RIYADH_NE_CORNER_LATITUDE ((float)25.505344)
#define RIYADH_NE_CORNER_LONGITUDE ((float)47.319077)

#define RIYADH_SW_CORNER_LATITUDE ((float)23.933626)
#define RIYADH_SW_CORNER_LONGITUDE ((float)45.890855)

@interface RidesServiceManager : NSObject

+ (void) requestNewRide:(NSDictionary *)rideParameters :( void (^)(NSDictionary *))completion;

+(void)requestTripEstimation:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+(void)requestETAEstimation:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+(void)cancelRideRequest:(NSDictionary *)parameters andRideID:(NSString *)rideID :( void (^)(NSDictionary *))completion;

+(void)getNearByDriversPupnubChannels:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+ (void)rateVehicleAndDriver:(NSDictionary *)parameters forRideID:(NSString *)rideID :(void(^)(NSDictionary *))completion;

+(void)getRide:(NSString *)rideID :(void (^)(NSDictionary *))completion;
    
+(void)dismissLastRideCancelation :( void (^)(NSDictionary *))completion;



+(GMSMapStyle *)setMapStyleFromFileName : (NSString *)fileName;

+(void)getPreviousRides :( void (^)(NSDictionary *))completion;

+(void)getCancelationReasons :(void (^)(NSDictionary *))completion;



+(void)addFavourites:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+(void)getNearbyPleaces:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+(void)getRecentPlaces :( void (^)(NSDictionary *))completion;

+(NSDictionary *)prepareRideDictionary:(NSDictionary *)rideDictionary;
+(NSDictionary *)prepareRideCardDictionary:(NSDictionary *)rideDictionary;
+(NSDictionary *)prepareRideReceiptDictionary:(NSDictionary *)rideDictionary;
@end

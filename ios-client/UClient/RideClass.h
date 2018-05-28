//
//  RideClass.h
//  Ego
//
//  Created by Mahmoud Amer on 7/13/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HelperClass.h"

@interface RideClass : NSObject

@property (nonatomic, strong) NSString *rideID;

@property (nonatomic, strong) NSDictionary *acceptedClientLocation;
@property (nonatomic, strong) NSDictionary *acceptedDriverLocation;

@property (nonatomic, strong) NSDictionary *arrivedClientLocation;
@property (nonatomic, strong) NSDictionary *arrivedDriverLocation;

@property (nonatomic, strong) NSDictionary *cancellationClientLocation;
@property (nonatomic, strong) NSDictionary *cancellationDriverLocation;

@property (nonatomic, strong) NSDictionary *clearanceClientLocation;
@property (nonatomic, strong) NSDictionary *clearanceDriverLocation;

@property (nonatomic, strong) NSDictionary *finishedDriverLocation;
@property (nonatomic, strong) NSDictionary *finishedClientLocation;

@property (nonatomic, strong) NSDictionary *dropoffLocation;
@property (nonatomic, strong) NSDictionary *initiatedClientLocation;

@property (nonatomic, strong) NSDictionary *lastClientLocation;
@property (nonatomic, strong) NSDictionary *lastDriverLocation;

@property (nonatomic, strong) NSDictionary *nearbyClientLocation;
@property (nonatomic, strong) NSDictionary *nearbyDriverLocation;

@property (nonatomic, strong) NSDictionary *onRideClientLocation;
@property (nonatomic, strong) NSDictionary *onRideDriverLocation;

@property (nonatomic, strong) NSDictionary *pickupLocation;

@property (nonatomic, strong) NSString *pickupLocationPhotoUrl;


@property (nonatomic, strong) NSNumber *acceptedTime;
@property (nonatomic, strong) NSNumber *initiatedTime;

@property (nonatomic, strong) NSString *arabicDropoffAddress;
@property (nonatomic, strong) NSString *arabicPickupAddress;

@property (nonatomic, strong) NSString *englishDropoffAddress;
@property (nonatomic, strong) NSString *englishPickupAddress;

@property (nonatomic, strong) NSString *baseFare;
@property (nonatomic, strong) NSString *minFare;
@property (nonatomic, strong) NSString *outstandingFees;
@property (nonatomic, strong) NSString *revenue;
@property (nonatomic, strong) NSString *totalFare;
@property (nonatomic, strong) NSString *surgeFactor;

@property (nonatomic, strong) NSString *cancellationFee;
@property (nonatomic, strong) NSString *cancellationFeeApplied;
@property (nonatomic, strong) NSString *cashPaidByClient;

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *paymentMethod;
@property (nonatomic, strong) NSString *peakOvercharge;


@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientRatingByDriver;
@property (nonatomic, strong) NSString *clientRatingStatus;
@property (nonatomic, strong) NSString *initiatedClientFirstName;
@property (nonatomic, strong) NSString *initiatedClientRating;

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *discount;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *driverCommision;

@property (nonatomic, strong) NSString *driverId;
@property (nonatomic, strong) NSString *driverRatingByClient;
@property (nonatomic, strong) NSString *driverRatingStatus;
@property (nonatomic, strong) NSString *duration;

@property (nonatomic, strong) NSString *isLuggage;
@property (nonatomic, strong) NSString *isQuiet;

@property (nonatomic, strong) NSString *promocode;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) NSString *vehicleRatingByClient;


-(id)initWithData:(NSDictionary *)rideData;
-(void)setToNil;

@end

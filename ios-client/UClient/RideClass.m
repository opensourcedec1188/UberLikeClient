//
//  RideClass.m
//  Ego
//
//  Created by Mahmoud Amer on 7/13/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "RideClass.h"

@implementation RideClass

-(id)initWithData:(NSDictionary *)rideData
{
    self = [super init];
    if(self)
    {
        NSLog(@"Here in RideClass %@", rideData);
        self.rideID = [rideData objectForKey:@"_id"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"acceptedClientLocation"]])
            self.acceptedClientLocation = [rideData objectForKey:@"acceptedClientLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"acceptedDriverLocation"]])
            self.acceptedDriverLocation = [rideData objectForKey:@"acceptedDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"arrivedClientLocation"]])
            self.arrivedClientLocation = [rideData objectForKey:@"arrivedClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"arrivedDriverLocation"]])
            self.arrivedDriverLocation = [rideData objectForKey:@"arrivedDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"cancellationClientLocation"]])
            self.cancellationClientLocation = [rideData objectForKey:@"cancellationClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"cancellationDriverLocation"]])
            self.cancellationDriverLocation = [rideData objectForKey:@"cancellationDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"cancellationDriverLocation"]])
            self.cancellationDriverLocation = [rideData objectForKey:@"cancellationDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"clearanceClientLocation"]])
            self.clearanceClientLocation = [rideData objectForKey:@"clearanceClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"clearanceDriverLocation"]])
            self.clearanceDriverLocation = [rideData objectForKey:@"clearanceDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"finishedDriverLocation"]])
            self.finishedDriverLocation = [rideData objectForKey:@"finishedDriverLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"finishedClientLocation"]])
            self.finishedClientLocation = [rideData objectForKey:@"finishedClientLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"dropoffLocation"]])
            self.dropoffLocation = [rideData objectForKey:@"dropoffLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"initiatedClientLocation"]])
            self.initiatedClientLocation = [rideData objectForKey:@"initiatedClientLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"lastClientLocation"]])
            self.lastClientLocation = [rideData objectForKey:@"lastClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"lastDriverLocation"]])
            self.lastDriverLocation = [rideData objectForKey:@"lastDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"nearbyClientLocation"]])
            self.nearbyClientLocation = [rideData objectForKey:@"nearbyClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"nearbyDriverLocation"]])
            self.nearbyDriverLocation = [rideData objectForKey:@"nearbyDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"onRideClientLocation"]])
            self.onRideClientLocation = [rideData objectForKey:@"onRideClientLocation"];
        if([HelperClass checkCoordinates:[rideData objectForKey:@"onRideDriverLocation"]])
            self.onRideDriverLocation = [rideData objectForKey:@"onRideDriverLocation"];
        
        if([HelperClass checkCoordinates:[rideData objectForKey:@"pickupLocation"]])
            self.pickupLocation = [rideData objectForKey:@"pickupLocation"];
        
        self.pickupLocationPhotoUrl = [rideData objectForKey:@"pickupLocationPhotoUrl"];
        self.acceptedTime = [rideData objectForKey:@"acceptedTime"];
        self.initiatedTime = [rideData objectForKey:@"initiatedTime"];
        
        if(([rideData objectForKey:@"arabicDropoffAddress"]) && !([[rideData objectForKey:@"arabicDropoffAddress"] isKindOfClass:[NSNull class]]))
            self.arabicDropoffAddress = [rideData objectForKey:@"arabicDropoffAddress"];
        self.arabicPickupAddress = [rideData objectForKey:@"arabicPickupAddress"];
        
        self.englishDropoffAddress = [rideData objectForKey:@"englishDropoffAddress"];
        self.englishPickupAddress = [rideData objectForKey:@"englishPickupAddress"];
        
        self.baseFare = [rideData objectForKey:@"baseFare"];
        self.minFare = [rideData objectForKey:@"minFare"];
        self.outstandingFees = [rideData objectForKey:@"outstandingFees"];
        self.revenue = [rideData objectForKey:@"revenue"];
        self.totalFare = [rideData objectForKey:@"totalFare"];
        self.surgeFactor = [rideData objectForKey:@"surgeFactor"];
        
        self.cancellationFee = [rideData objectForKey:@"cancellationFee"];
        self.cancellationFeeApplied = [rideData objectForKey:@"cancellationFeeApplied"];
        self.cashPaidByClient = [rideData objectForKey:@"cashPaidByClient"];
        
        self.category = [rideData objectForKey:@"category"];
        self.paymentMethod = [rideData objectForKey:@"paymentMethod"];
        self.peakOvercharge = [rideData objectForKey:@"peakOvercharge"];
        
        self.clientId = [rideData objectForKey:@"clientId"];
        self.clientRatingByDriver = [rideData objectForKey:@"clientRatingByDriver"];
        self.clientRatingStatus = [rideData objectForKey:@"clientRatingStatus"];
        self.initiatedClientFirstName = [rideData objectForKey:@"initiatedClientFirstName"];
        self.initiatedClientRating = [rideData objectForKey:@"initiatedClientRating"];
        
        self.comment = [rideData objectForKey:@"comment"];
        self.discount = [rideData objectForKey:@"discount"];
        self.distance = [rideData objectForKey:@"distance"];
        self.driverCommision = [rideData objectForKey:@"driverCommision"];
        
        self.driverId = [rideData objectForKey:@"driverId"];
        self.driverRatingByClient = [rideData objectForKey:@"driverRatingByClient"];
        self.driverRatingStatus = [rideData objectForKey:@"driverRatingStatus"];
        self.duration = [rideData objectForKey:@"duration"];
        
        self.isLuggage = [rideData objectForKey:@"isLuggage"];
        self.isQuiet = [rideData objectForKey:@"isQuiet"];
        
        self.promocode = [rideData objectForKey:@"promocode"];
        
        self.status = [rideData objectForKey:@"status"];
        
        self.vehicleId = [rideData objectForKey:@"vehicleId"];
        self.vehicleRatingByClient = [rideData objectForKey:@"vehicleRatingByClient"];
        
    }
    return self;
}


-(void)setToNil{
    self.rideID = nil;
    self.acceptedClientLocation = nil;
    self.acceptedDriverLocation = nil;
    
    self.arrivedClientLocation = nil;
    self.arrivedDriverLocation = nil;
    
    self.cancellationClientLocation = nil;
    self.cancellationDriverLocation = nil;
    
    self.clearanceClientLocation = nil;
    self.clearanceDriverLocation = nil;
    
    self.finishedDriverLocation = nil;
    self.finishedClientLocation = nil;
    
    self.dropoffLocation = nil;
    self.initiatedClientLocation = nil;
    
    self.lastClientLocation = nil;
    self.lastDriverLocation = nil;
    
    self.nearbyClientLocation = nil;
    self.nearbyDriverLocation = nil;
    
    self.onRideClientLocation = nil;
    self.onRideDriverLocation = nil;
    
    self.pickupLocation = nil;
    
    self.pickupLocationPhotoUrl = nil;
    self.acceptedTime = nil;
    self.initiatedTime = nil;
    
    self.arabicDropoffAddress = nil;
    self.arabicPickupAddress = nil;
    
    self.englishDropoffAddress = nil;
    self.englishPickupAddress = nil;
    
    self.baseFare = nil;
    self.minFare = nil;
    self.outstandingFees = nil;
    self.revenue = nil;
    self.totalFare = nil;
    self.surgeFactor = nil;
    
    self.cancellationFee = nil;
    self.cancellationFeeApplied = nil;
    self.cashPaidByClient = nil;
    
    self.category = nil;
    self.paymentMethod = nil;
    self.peakOvercharge = nil;
    
    self.clientId = nil;
    self.clientRatingByDriver = nil;
    self.clientRatingStatus = nil;
    self.initiatedClientFirstName = nil;
    self.initiatedClientRating = nil;
    
    self.comment = nil;
    self.discount = nil;
    self.distance = nil;
    self.driverCommision = nil;
    
    self.driverId = nil;
    self.driverRatingByClient = nil;
    self.driverRatingStatus = nil;
    self.duration = nil;
    
    self.isLuggage = nil;
    self.isQuiet = nil;
    
    self.promocode = nil;
    
    self.status = nil;
    
    self.vehicleId = nil;
    self.vehicleRatingByClient = nil;
}

@end

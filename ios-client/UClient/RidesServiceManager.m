//
//  RidesServiceManager.m
//  Ego
//
//  Created by MacBookPro on 4/25/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "RidesServiceManager.h"

@implementation RidesServiceManager



+ (void) requestNewRide:(NSDictionary *)rideParameters :( void (^)(NSDictionary *))completion
{
    NSString *URLString = [NSString stringWithFormat:@"%@/rides", BASE_URL];
    NSLog(@"Will request ride : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager POST:URLString parameters:rideParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"requestNewRide error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)requestTripEstimation:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion {
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/estimate3", BASE_URL];
    NSLog(@"Will estimate ride : %@ ", parameters);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)requestETAEstimation:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion {
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/estimate", BASE_URL];
    NSLog(@"Will estimate ride : %@ ", parameters);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)cancelRideRequest:(NSDictionary *)parameters andRideID:(NSString *)rideID :( void (^)(NSDictionary *))completion {
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/%@/cancel", BASE_URL, rideID];
    NSLog(@"Will cancel ride : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}


+(void)getNearByDriversPupnubChannels:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@/nearby-drivers-channels", BASE_URL, [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+ (void)rateVehicleAndDriver:(NSDictionary *)parameters forRideID:(NSString *)rideID :(void(^)(NSDictionary *))completion {
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/%@/rate", BASE_URL, rideID];
    NSLog(@"Will rate : %@ and parameters : %@ ", URLString, parameters);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getRide:(NSString *)rideID :(void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/%@", BASE_URL, rideID];
    NSLog(@"Will get ride URL : %@", URLString);
    if(rideID.length > 0)
    {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
        [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
        
        [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            completion((NSDictionary *)responseObject);
            [manager invalidateSessionCancelingTasks:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                NSLog(@"ride get error : %@", failureResponseBody);
                completion(failureResponseBody);
            }else{
                completion(nil);
            }
            [manager invalidateSessionCancelingTasks:YES];
        }];
        
    }else{
        NSLog(@"NO rideID passed");
        completion(nil);
    }
}
    
+(void)dismissLastRideCancelation :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@/dismiss-last-ride-message", BASE_URL, [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]];
    NSLog(@"Will rate : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        
    }];
}

+(GMSMapStyle *)setMapStyleFromFileName : (NSString *)fileName{
    // Set the map style by passing the URL for style.json.
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:fileName withExtension:@"json"];
    NSError *error;
    
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style)
        return nil;
    else
        return style;
}

+(void)getPreviousRides :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/rides/", BASE_URL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"ride get error : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getCancelationReasons :(void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/cancellation-reasons", BASE_URL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"cancellation-reasons get error : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)addFavourites:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@/favorites/%@", BASE_URL, [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"], [parameters objectForKey:@"type"]];
    NSLog(@"Will set favourite ride : %@ ", parameters);
    NSLog(@"urlString : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getNearbyPleaces:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@/nearby-places", BASE_URL, [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]];
    NSLog(@"Will get nearby places : %@ ", parameters);
    NSLog(@"getNearbyPleaces urlString : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getNearbyPleaces error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"getNearbyPleaces error body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getRecentPlaces :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@/recent-places?language=%@", BASE_URL, [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"], [HelperClass getDeviceLanguage]];
    NSLog(@"getRecentPlaces urlString : %@ ", URLString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"getRecentPlaces error : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(NSDictionary *)prepareRideDictionary:(NSDictionary *)rideDictionary {
    if(!rideDictionary)
        return nil;
    if(![rideDictionary objectForKey:@"_id"])
        return nil;
    
    if(![rideDictionary objectForKey:@"pickupLocation"])
        return nil;
    
    NSMutableDictionary *mutableRideCard = [rideDictionary mutableCopy];
    
    if(![mutableRideCard objectForKey:@"pickupLocation"])
        [mutableRideCard setObject:@"" forKey:@"pickupLocation"];
    
    if(![mutableRideCard objectForKey:@"dropoffLocation"])
        [mutableRideCard setObject:@"" forKey:@"dropoffLocation"];
    
    if(![mutableRideCard objectForKey:@"lastDriverLocation"])
        [mutableRideCard setObject:@"" forKey:@"lastDriverLocation"];
    
    if(![mutableRideCard objectForKey:@"status"])
        [mutableRideCard setObject:@"" forKey:@"status"];
    
    if(![mutableRideCard objectForKey:@"canceledBy"])
        [mutableRideCard setObject:@"" forKey:@"canceledBy"];
    
    if(![mutableRideCard objectForKey:@"englishDropoffAddress"])
        [mutableRideCard setObject:@"" forKey:@"englishDropoffAddress"];
    
    if(![mutableRideCard objectForKey:@"onRideDriverLocation"])
        [mutableRideCard setObject:@"" forKey:@"onRideDriverLocation"];
    
    if(![mutableRideCard objectForKey:@"isLuggage"])
        [mutableRideCard setObject:[NSNumber numberWithInteger:0] forKey:@"isLuggage"];
    
    if(![mutableRideCard objectForKey:@"isQuiet"])
        [mutableRideCard setObject:[NSNumber numberWithInteger:0] forKey:@"isQuiet"];
    
    if(![mutableRideCard objectForKey:@"comment"])
        [mutableRideCard setObject:@"" forKey:@"comment"];
    
    if(![mutableRideCard objectForKey:@"category"])
        [mutableRideCard setObject:@"" forKey:@"category"];
    
    
    return [mutableRideCard copy];
}

+(NSDictionary *)prepareRideCardDictionary:(NSDictionary *)rideDictionary {
    NSLog(@"prepareRideCardDictionary : %@", rideDictionary);
    if(!rideDictionary)
        return nil;
    if(![rideDictionary objectForKey:@"_id"])
        return nil;
    if(![rideDictionary objectForKey:@"card"])
        return nil;
    
    NSMutableDictionary *mutableRideCard = [[rideDictionary objectForKey:@"card"] mutableCopy];
    if(![mutableRideCard objectForKey:@"driverFirstName"])
        [mutableRideCard setObject:@"" forKey:@"driverFirstName"];
    
    if(![mutableRideCard objectForKey:@"vehicleColor"])
        [mutableRideCard setObject:@"" forKey:@"vehicleColor"];
    
    if(![mutableRideCard objectForKey:@"vehicleManufacturer"])
        [mutableRideCard setObject:@"" forKey:@"vehicleManufacturer"];
    
    if(![mutableRideCard objectForKey:@"vehicleModel"])
        [mutableRideCard setObject:@"" forKey:@"vehicleModel"];
    
    if(![mutableRideCard objectForKey:@"time"])
        [mutableRideCard setObject:@"" forKey:@"time"];
    
    if(![mutableRideCard objectForKey:@"fare"])
        [mutableRideCard setObject:@"" forKey:@"fare"];
    
    if(![mutableRideCard objectForKey:@"isCanceled"])
        [mutableRideCard setObject:@"" forKey:@"isCanceled"];
    
    if(![mutableRideCard objectForKey:@"canceledBy"])
        [mutableRideCard setObject:@"" forKey:@"canceledBy"];
    
    if(![mutableRideCard objectForKey:@"rating"])
        [mutableRideCard setObject:@"" forKey:@"rating"];
    
    return [mutableRideCard copy];
}

+(NSDictionary *)prepareRideReceiptDictionary:(NSDictionary *)rideDictionary {
    NSLog(@"prepareRideCardDictionary : %@", rideDictionary);
    if(!rideDictionary)
        return nil;
    if(![rideDictionary objectForKey:@"_id"])
        return nil;
    if(![rideDictionary objectForKey:@"receipt"])
        return nil;
    
    NSMutableDictionary *mutableRideCard = [[rideDictionary objectForKey:@"receipt"] mutableCopy];
    if(![mutableRideCard objectForKey:@"mapPhotoUrl"])
        [mutableRideCard setObject:@"" forKey:@"mapPhotoUrl"];
    
    if(![mutableRideCard objectForKey:@"driverPhotoUrl"])
        [mutableRideCard setObject:@"" forKey:@"driverPhotoUrl"];
    
    if(![mutableRideCard objectForKey:@"vehicleManufacturer"])
        [mutableRideCard setObject:@"" forKey:@"vehicleManufacturer"];
    
    if(![mutableRideCard objectForKey:@"driverFirstName"])
        [mutableRideCard setObject:@"" forKey:@"driverFirstName"];
    
    if(![mutableRideCard objectForKey:@"time"])
        [mutableRideCard setObject:@"" forKey:@"time"];
    
    if(![mutableRideCard objectForKey:@"startAddress"])
        [mutableRideCard setObject:@"" forKey:@"startAddress"];
    
    if(![mutableRideCard objectForKey:@"endAddress"])
        [mutableRideCard setObject:@"" forKey:@"endAddress"];
    
    if(![mutableRideCard objectForKey:@"totalFare"])
        [mutableRideCard setObject:@"" forKey:@"totalFare"];
    
    if(![mutableRideCard objectForKey:@"isCanceled"])
        [mutableRideCard setObject:[NSNumber numberWithInteger:0] forKey:@"isCanceled"];
    
    if(![mutableRideCard objectForKey:@"canceledBy"])
        [mutableRideCard setObject:@"" forKey:@"canceledBy"];
    
    if(![mutableRideCard objectForKey:@"rating"])
        [mutableRideCard setObject:@"" forKey:@"rating"];
    
    return [mutableRideCard copy];
    
}

@end

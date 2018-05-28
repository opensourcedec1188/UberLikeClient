//
//  ProfileServiceManager.h
//  Ego
//
//  Created by Mahmoud Amer on 7/31/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <UIImage+AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>
#import <SAMKeychain.h>
#import "ServiceManager.h"
#import "HelperClass.h"

@interface ProfileServiceManager : NSObject

+ (void)updateProfileData:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+ (void)updatePasswordData:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+(void) validatePassword:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;

+ (void)sendChangePhoneOTP:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+ (void)changeMobile:(NSDictionary *)parameters :( void (^)(NSDictionary *))completion;

+ (BOOL)uploadClientPhoto:(UIImage *)image :(void (^)(NSDictionary *))completion;

+ (void)getRideData:(NSString *)rideID :( void (^)(NSDictionary *))completion;

+(void)getGeneralHelpOptions :( void (^)(NSDictionary *))completion;

+(void)getRideHelpOptions :( void (^)(NSDictionary *))completion;

+(void)getClientImage:(NSString *)urlString :( void (^)(NSData *))completion;

+(void)enableUsingWallet :( void (^)(NSDictionary *))completion;

+(void)disableUsingWallet :( void (^)(NSDictionary *))completion;
@end

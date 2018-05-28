//
//  ServiceManager.h
//  Ego
//
//  Created by MacBookPro on 3/2/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>
#import <SAMKeychain/SAMKeychain.h>

#import "HelperClass.h"


#define BASE_URL @"https://www.procabnow.com/api/v0" /* Back-End base url */

/* Keychain constants */
#define SERVICE_NAME @"procab_client" /* Keychain service name for access token */
#define CLIENT_ACCESS_TOKEN_KEY @"clientAccessToken" /* keychain key for service token */

#define CLIENT_PHONE_SESSION_ACCESS_TOKEN_KEY @"clientPhoneSession"

/* User defaults keys constants */
#define UD_CLIENT_LOGGED_IN @"procab_client_logged_in" /* Bool represents user logged in or not in UserDefaults */
#define UD_CLIENT_DATA @"procab_client_data" /* dictionary represents full client data in userDefaults */

/* Client data as per Back-End response */
#define CLIENTDATA_API_ID @"_id"
#define CLIENTDATA_API_EMAIL @"email"
#define CLIENTDATA_API_DIALCODE @"dialCode"
#define CLIENTDATA_API_FNAME @"firstName"
#define CLIENTDATA_API_LNAME @"lastName"
#define CLIENTDATA_API_LANGUAGE @"language"
#define CLIENTDATA_API_GENDER @"gender"
#define CLIENTDATA_API_PHONE @"phone"
#define CLIENTDATA_API_REFERRAL_CODE @"referralCode"

@interface ServiceManager : NSObject
{
    
}

+ (void) setClientState :( void (^)(NSDictionary *))completion;

+ (void)getClientData:(NSString *)clientID :( void (^)(NSDictionary *))completion;

/*
 Get App Rules
 Return: Rules Data
 */

+ (void)getAppRules :( void (^)(NSDictionary *))completion;
#pragma mark - Registeration
/*
 SMS Message Request OTP
 Params:
 Return:
 */
+ (void)requestOTPCode:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;

/*
 Confirm OTP Code
 Params:
 Return:
 */
+(void)confirmOTPCode:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;

/* Save phone session to keychain after confirming OTP To be used in driver registration */
+(BOOL)savePhoneSession:(NSString *)accessToken;
/* Get phone session from keychain */
+(NSString *)getPhoneSession;

+(void)deletePhoneSessionFromKeychain;

/*
 Full Register Request
 Params:
 Return:
 */
+(BOOL)FullDataRegister:(NSDictionary *)fullData :(void (^)(NSDictionary *))completion;


#pragma mark - Sign in
/*
 Login Request
 Params: role, device, email, password
 Return: data { accessToken, device, role, userId }
 */

+ (void)clientLogin:(NSDictionary *)loginData :( void (^)(NSDictionary *))completion;

#pragma mark - Forget Password Work
+ (void)sendResetPasswordOTP:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;
+ (void)confirmResetPasswordOTP:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;
+ (void)resetNewPassword:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion;


#pragma mark - Save logged-in client data
/*
 Login Request
 Params: role, device, email, password
 Return: data { accessToken, device, role, userId }
 */
+ (BOOL)saveLoggedInClientData:(NSDictionary *)clientData andAccessToken:(NSString *)accessToken;

+(NSDictionary *)getClientDataFromUserDefaults;


+(NSString *)getAccessTokenFromKeychain;

#pragma mark - Logout
+(BOOL)clientLogout :(void (^)(NSDictionary *))completion;

#pragma mark - Delete Client
+ (BOOL)deleteLoggedInClientDataFromDevice;

@end

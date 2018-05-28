//
//  ServiceManager.m
//  Ego
//
//  Created by MacBookPro on 3/2/17.
//  Copyright © 2017 Procab. All rights reserved.
//

#import "ServiceManager.h"


@implementation ServiceManager

+ (void) setClientState :( void (^)(NSDictionary *))completion{
    
    if([self getClientDataFromUserDefaults]){
        
        NSDictionary *loggedInClient = [self getClientDataFromUserDefaults];
        
        if([HelperClass checkNetworkReachability]){
            //Get Last updated client data from server
            [self getClientData:[loggedInClient objectForKey:@"_id"] :^(NSDictionary *client) {
                NSLog(@"loggedInClient : %@", client);
                if([client objectForKey:@"data"]){
                    NSDictionary *updatedClient = [client objectForKey:@"data"];
                    //Update driver data with the new data from server
                    [self saveLoggedInClientData:updatedClient andAccessToken:[[client objectForKey:@"session"] objectForKey:@"accessToken"]];
                    //Check if on ride, Go onRideScreen
                    if([[updatedClient objectForKey:@"isOnRide"] intValue] == 1){
                        NSDictionary *currentRide = (NSDictionary *)[client objectForKey:@"currentRide"];
                        if(currentRide){
                            NSDictionary *state = @{
                                                    @"segue" : @"splashGoHome",//@"splashGoOnRideScreen",
                                                    @"description" : @"onRide",
                                                    @"currentRide" : currentRide
                                                    };
                            completion(state);
                        }else{
                            NSDictionary *state = @{
                                                    @"segue" : @"splashGoHome",
                                                    @"description" : @"home"
                                                    };
                            completion(state);
                        }
                    }else{
                        //Not on ride
                        //1- Not rated, Go rating
                        //Canceled by driver/System/TechSupport -- Handle cancelation
                        //else, Go gome
                        
                        NSString *lastRideMessage = [updatedClient objectForKey:@"lastRideMessage"];
                        NSDictionary *state;
                        
                        if([lastRideMessage isEqualToString:@"not-rated"]){
                            state = @{
                                      @"segue" : @"splashGoHome",//@"splashGoRating",
                                      @"description" : @"rating"
                                      };
                        }else if(([lastRideMessage isEqualToString:@"canceled-by-driver"]) || ([lastRideMessage isEqualToString:@"canceled-by-system"]) || ([lastRideMessage isEqualToString:@"canceled-by-tech-support"])){
                            state = @{
                                      @"segue" : @"splashGoHome",//@"splashGoOnRideScreen",
                                      @"description" : @"ride-canceled"
                                      };
                        }else{
                            state = @{
                                      @"segue" : @"splashGoHome",
                                      @"description" : @"home"
                                      };
                        }
                        completion(state);
                    }
                }else{
                    if(([[client objectForKey:@"code"] intValue] == 401) || ([[client objectForKey:@"code"] intValue] == 404)){
                        //Failed to get client on server
                        NSDictionary *state = @{
                                                @"segue" : @"splashGoLogin",
                                                @"description" : @"login"
                                                };
                        completion(state);
                    }else{
                        //Failed to get client on server
                        NSDictionary *state = @{
                                                @"segue" : @"splashGoHome",
                                                @"description" : @"home"
                                                };
                        completion(state);
                    }
                }
            }];
        }else{
            NSDictionary *state = @{
                                    @"segue" : @"splashGoHome",
                                    @"description" : @"home",
                                    @"network" : @"not_reachable"
                                    };
            completion(state);
        }
        
        
    }else{//Not logged in, Should go to login page
        completion(@{@"segue" : @"splashGoLogin", @"description" : @"login"});
    }
}

+ (void)getClientData:(NSString *)clientID :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/%@", BASE_URL, clientID];
    NSLog(@"Will getClientData URL : %@", URLString);
    if(clientID.length > 0)
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
                NSLog(@"client get error : %@", failureResponseBody);
                completion(failureResponseBody);
            }else{
                completion(nil);
            }
            [manager invalidateSessionCancelingTasks:YES];
        }];
        
    }else{
        NSLog(@"NO clientID passed");
        completion(nil);
    }
}

#pragma mark - Rules
/*
 Get App Rules
 Return: Rules Data
 */

+ (void)getAppRules :( void (^)(NSDictionary *))completion
{
    NSString *URLString = [NSString stringWithFormat:@"%@/rules", BASE_URL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"code: %@", [responseObject objectForKey:@"code"]);
        completion(responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
        NSLog(@"error: %@", error.localizedDescription);
        [manager invalidateSessionCancelingTasks:YES];
    }];
    
}

#pragma mark - Registeration

/*
 SMS Message Request OTP
 Params: phone number
 Return: true or false
 */
+ (void)requestOTPCode:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion {
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/send-otp", BASE_URL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
/*
 Confirm Confirm OTP Code
 Params: OTP code, Phone number
 Return: Yes if
 */
+(void)confirmOTPCode:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion {
    //URL String
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/verify-otp", BASE_URL];
    //Request Parameters
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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

/* Save phone session after confirming OTP To be used in client registration */
+(BOOL)savePhoneSession:(NSString *)accessToken{
    
    BOOL result = YES;
    
    [SAMKeychain deletePasswordForService:SERVICE_NAME account:CLIENT_PHONE_SESSION_ACCESS_TOKEN_KEY];
    
    if(![SAMKeychain setPassword:accessToken forService:SERVICE_NAME account:CLIENT_PHONE_SESSION_ACCESS_TOKEN_KEY])
        result = NO;
    return result;
}
+(NSString *)getPhoneSession
{
    return [SAMKeychain passwordForService:SERVICE_NAME account:CLIENT_PHONE_SESSION_ACCESS_TOKEN_KEY];
}

+(void)deletePhoneSessionFromKeychain
{
    [SAMKeychain deletePasswordForService:SERVICE_NAME account:CLIENT_PHONE_SESSION_ACCESS_TOKEN_KEY];
}


/*
 Full Register Request
 Params:
 Return:
 */
+(BOOL) FullDataRegister:(NSDictionary *)fullData :(void (^)(NSDictionary *))completion
{
    
    NSString *URLString = [NSString stringWithFormat:@"%@/clients", BASE_URL];
    NSLog(@"Will RegisterFullData : %@ and URL : %@", fullData, URLString);
    if(fullData)
    {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[self getPhoneSession] forHTTPHeaderField:@"X-Access-Token"];
        [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
        
        [manager POST:URLString parameters:fullData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success! responseObject:  %@", responseObject);
            completion((NSDictionary *)responseObject);
            [manager invalidateSessionCancelingTasks:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
    }else{
        NSLog(@"validation not passed");
        return NO;
    }
    return YES;
}


#pragma mark - Sign in
/*
 Login Request
 Params: NSDictionary (role, device, email, password)
 Return: data { accessToken, device, role, userId }
 */

+ (void)clientLogin:(NSDictionary *)loginData :( void (^)(NSDictionary *))completion
{
    NSString *URLString = [NSString stringWithFormat:@"%@/sessions", BASE_URL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager POST:URLString parameters:loginData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success! %@", responseObject);
        if(([responseObject objectForKey:@"data"]) && [[responseObject objectForKey:@"data"] objectForKey:@"accessToken"])
            [self saveLoggedInClientData:[responseObject objectForKey:@"user"] andAccessToken:[[responseObject objectForKey:@"data"] objectForKey:@"accessToken"]];
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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

#pragma mark - Forget Password Work
+ (void)sendResetPasswordOTP:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/send-reset-password-otp", BASE_URL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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

+ (void)confirmResetPasswordOTP:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion{
    //URL String
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/verify-reset-password-otp", BASE_URL];
    //Request Parameters
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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

+ (void)resetNewPassword:(NSDictionary *)parameters :(void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/clients/reset-password", BASE_URL];
    NSLog(@"Will RegisterFullData : %@ and URL : %@", parameters, URLString);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[self getPhoneSession] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"resetNewPassword -- success! responseObject:  %@", responseObject);
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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


#pragma mark - Save logged-in client data
/*
 Login Request
 Params: client data dictionary
 Return: True if saved
 */
+ (BOOL)saveLoggedInClientData:(NSDictionary *)clientData andAccessToken:(NSString *)accessToken
{
    BOOL result = YES;
    if(clientData && accessToken)
    {
        [SAMKeychain deletePasswordForService:SERVICE_NAME account:CLIENT_ACCESS_TOKEN_KEY];
        /* First, Save access token in device keychain */
        if(![SAMKeychain setPassword:accessToken forService:SERVICE_NAME account:CLIENT_ACCESS_TOKEN_KEY])
            result = NO;
        
        /* Second, Save user data to user defaults */
        /* Logged in = yes */
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:UD_CLIENT_LOGGED_IN];
        /* Client Data Dictionary */
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:clientData] forKey:UD_CLIENT_DATA];
        
    }else{
        //Update Client
        /* Client data */
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:clientData] forKey:UD_CLIENT_DATA];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return result;
}

+(NSDictionary *)getClientDataFromUserDefaults
{
    NSDictionary *clientData = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:UD_CLIENT_DATA]];
//    NSLog(@"client on this device : %@", clientData);
    return clientData;
}

+(NSString *)getAccessTokenFromKeychain
{
    return [SAMKeychain passwordForService:SERVICE_NAME account:CLIENT_ACCESS_TOKEN_KEY];
}

#pragma mark - Logout
+(BOOL)clientLogout :(void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"%@/sessions/current", BASE_URL];
    NSLog(@"Will logout client : %@ ", [self getAccessTokenFromKeychain]);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[self getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager DELETE:URLString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"logout success! %@", responseObject);
        if([responseObject objectForKey:@"data"]){
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UD_CLIENT_LOGGED_IN];
        }
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        NSLog(@"error: %@", error.localizedDescription);
        [manager invalidateSessionCancelingTasks:YES];
    }];
    
    return YES;
}

#pragma mark - Delete logged-in client from device UserDefaults and Keychain
+ (BOOL)deleteLoggedInClientDataFromDevice
{
    BOOL result = YES;
    if(![SAMKeychain deletePasswordForService:SERVICE_NAME account:CLIENT_ACCESS_TOKEN_KEY])
        result = NO;
        
    /* Second, Delete user data from NSUserDefaults */
    /* Logged in = NO */
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UD_CLIENT_LOGGED_IN];
    
    /* Delete client data from NSUserDefaults */
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UD_CLIENT_DATA];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentRegistrationStep"];
    return result;
}


@end

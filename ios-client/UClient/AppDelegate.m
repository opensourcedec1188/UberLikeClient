//
//  AppDelegate.m
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "AppDelegate.h"

@import UserNotifications;

@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _lastRideData = [[NSDictionary alloc] init];
    //Clear Old Notifications
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    
    [NewRelicAgent startWithApplicationToken:NEWRELIC_APP_TOKEN];
    
    [GMSServices provideAPIKey:GMS_SERVICE_KEY];
    [GMSPlacesClient provideAPIKey:GMS_SERVICE_KEY];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    //Splash screen should decide where to go
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    /*Pubnub Push Notifications*/
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 10) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                    // This means we have not yet asked for notification permissions
                case UNAuthorizationStatusNotDetermined:
                {
                    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        // You might want to remove this, or handle errors differently in production
                        NSAssert(error == nil, @"There should be no error");
                        if (granted) {
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                        }
                    }];
                }
                    break;
                    // We are already authorized, so no need to ask
                case UNAuthorizationStatusAuthorized:
                {
                    // Just try and register for remote notifications
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
                    break;
                    // We are denied User Notifications
                case UNAuthorizationStatusDenied:
                {
                    // Possibly display something to the user
                    UIAlertController *useNotificationsController = [UIAlertController alertControllerWithTitle:@"Turn on notifications" message:@"This app needs notifications turned on for the best user experience" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *goToSettingsAction = [UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                    [useNotificationsController addAction:goToSettingsAction];
                    [useNotificationsController addAction:cancelAction];
                    [self.window.rootViewController presentViewController:useNotificationsController animated:true completion:nil];
                    NSLog(@"We cannot use notifications because the user has denied permissions");
                }
                    break;
            }
            
        }];
    } else if ((systemVersion < 10) || (systemVersion >= 8)) {
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound |
                                        UIUserNotificationTypeAlert);
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        NSLog(@"We cannot handle iOS 7 or lower in this example. Contact support@pubnub.com");
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    if(([url query]) && ([url query].length > 0) && !([[url query] isKindOfClass:[NSNull class]])){
        NSString *queryString = [url query];
        NSArray *queryArgs = [queryString componentsSeparatedByString:@"ion="];
        _stringFromShareExtension = [queryArgs objectAtIndex:1];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *hexToken = [HelperClass HEXFromDevicePushToken:deviceToken];
    
    NSLog(@"tokenString : %@", hexToken);
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults] setObject:hexToken forKey:@"DeviceTokenString"];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
        NSLog(@"App already open");
    } else {
        NSLog(@"App opened from Notification : %@", userInfo);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [_locationManager stopUpdatingLocation];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_locationManager startUpdatingLocation];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
}




@end

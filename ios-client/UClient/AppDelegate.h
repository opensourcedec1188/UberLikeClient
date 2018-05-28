//
//  AppDelegate.h
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <NewRelicAgent/NewRelic.h>

#import "ServiceManager.h"
#import "SplashViewController.h"

//Constants Keys


#define NEWRELIC_APP_TOKEN @"AA6390d582ba69c7c06695b911ab5d7bc74c542794"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    
}

@property (strong) CLLocationManager *locationManager;
@property (strong) CLLocation *currentLocation;

@property (strong) NSString *stringFromShareExtension;

@property (strong, nonatomic) UIWindow *window;

@property (strong) NSDictionary *lastRideData;

@end


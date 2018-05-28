//
//  LocalNotification.m
//  Ego
//
//  Created by MacBookPro on 5/4/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNotification.h"

static LocalNotification*   localNotification = nil;

@interface LocalNotification(){
    UIApplication* application;
}

@end

@implementation LocalNotification


- (instancetype)init{
    self = [super init];
    if (self) {
        application = [UIApplication sharedApplication];
    }
    return self;
}

+ (LocalNotification*)standardLocalNotification {
    
    @synchronized(self) {
        if(nil == localNotification) {
            localNotification = [LocalNotification alloc];
        }
    }
    return localNotification;
}

- (void)scheduleAlert:(NSString*)alertBody {
    
    [self scheduleAlert:alertBody fireDate:[[NSDate date] dateByAddingTimeInterval:1]];
}

- (void)scheduleAlert:(NSString*)alertBody fireDate:(NSDate*)fireDate{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Something went wrong");
                              }
                          }];

    
}

@end

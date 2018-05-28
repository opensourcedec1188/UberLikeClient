//
//  LocalNotification.h
//  Ego
//
//  Created by MacBookPro on 5/4/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UserNotifications;

@interface LocalNotification : NSObject

+ (LocalNotification*)standardLocalNotification;

- (void)scheduleAlert:(NSString*)alertBody;

- (void)scheduleAlert:(NSString*)alertBody fireDate:(NSDate*)fireDate;


@end

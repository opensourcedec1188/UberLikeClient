//
//  PupnubRideManager.h
//  Ego
//
//  Created by MacBookPro on 5/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PubNub/PubNub.h>

#import "ServiceManager.h"

@protocol PupnubRideManagerDelegate <NSObject>
@required
-(void)receivedMessageFromDriverOnPupnub:(NSDictionary *)message;
@end

@interface PupnubRideManager : NSObject <PNObjectEventListener> {
    
}

@property (nonatomic, weak) id <PupnubRideManagerDelegate> listnerDelegate;

@property (strong) PNConfiguration *configuration;
@property (nonatomic, strong) PubNub *client;

- (id)initManager;


-(void)endListening;
-(id)initForNearByWithChannelsArray:(NSArray *)channels;
-(void)listenToChannelName:(NSString *)channelName;
-(void)listenToNearbyDrivers:(NSArray *)channels;

@end

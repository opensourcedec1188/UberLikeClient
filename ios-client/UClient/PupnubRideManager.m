//
//  PupnubRideManager.m
//  Ego
//
//  Created by MacBookPro on 5/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "PupnubRideManager.h"

@implementation PupnubRideManager

#pragma mark Singleton Methods
+(id)sharedManager
{
    NSLog(@"sharedManager initialized");
    static PupnubRideManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (id)initManager {
    if (self = [super init]) {
        self.configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-79b1311e-caae-4dab-aba0-6a9c6edc8c24" subscribeKey:@"sub-c-a64d88be-2fde-11e7-8f36-0619f8945a4f"];
        self.configuration.uuid = [NSString stringWithFormat:@"client-%@", [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]];//[NSUUID UUID].UUIDString.lowercaseString;

        NSLog(@"accesstoke : %@", [ServiceManager getAccessTokenFromKeychain]);
        self.configuration.authKey = [ServiceManager getAccessTokenFromKeychain];
        self.client = [PubNub clientWithConfiguration:self.configuration];
    }
    return self;
}

-(id)initForNearByWithChannelsArray:(NSArray *)channels {
    NSLog(@"channels : %@", channels);
    if (self = [super init]) {
        self.configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-79b1311e-caae-4dab-aba0-6a9c6edc8c24" subscribeKey:@"sub-c-a64d88be-2fde-11e7-8f36-0619f8945a4f"];
        self.configuration.uuid = [NSString stringWithFormat:@"client-%@", [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]];//[[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.configuration.authKey = [ServiceManager getAccessTokenFromKeychain];
        self.client = [PubNub clientWithConfiguration:self.configuration];
        [self.client addListener:self];
        [self.client subscribeToChannels:channels withPresence:NO];
        
    }
    return self;
}

-(void)listenToChannelName:(NSString *)channelName{
    [self.client subscribeToChannels: @[channelName] withPresence:NO];
    [self.client addListener:self];
}

-(void)listenToNearbyDrivers:(NSArray *)channels{
    [self.client subscribeToChannels:channels withPresence:NO];
}

-(void)endListening{
    [self.client unsubscribeFromAll];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    // Handle new message stored in message.data.message
    if (![message.data.channel isEqualToString:message.data.subscription]) {
        
        // Message has been received on channel group stored in message.data.subscription.
    }
    else {
        
        // Message has been received on channel stored in message.data.channel.
    }
    
//    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
//          message.data.channel, message.data.timetoken);
    [[self listnerDelegate] receivedMessageFromDriverOnPupnub:message.data.message];
    
}

@end

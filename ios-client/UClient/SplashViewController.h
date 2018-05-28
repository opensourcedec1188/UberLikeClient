//
//  SplashViewController.h
//  Ego
//
//  Created by MacBookPro on 5/8/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServiceManager.h"
#import "ProfileServiceManager.h"
#import "HelperClass.h"
#import "AppDelegate.h"
#import "UIImage+animatedGIF.h"

#import "PickupConfirmationViewController.h"
#import "HomeViewController.h"

@interface SplashViewController : UIViewController {
    NSDictionary *currentRideDetails;
}
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;

@end

//
//  PickupConfirmationViewController.h
//  Ego
//
//  Created by MacBookPro on 4/29/17.
//  Copyright © 2017 Procab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <NotificationCenter/NotificationCenter.h>

#import <PubNub/PubNub.h>

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>

#import "HelperClass.h"
#import "UIHelperClass.h"
#import "RidesServiceManager.h"
#import "GoogleServicesManager.h"
#import "UIImageView+AFNetworking.h"

#import "OnRideViewController.h"
#import "HomeViewController.h"
#import "PickupLocationView.h"

@interface PickupConfirmationViewController : UIViewController <GMSMapViewDelegate, UNUserNotificationCenterDelegate, UITextFieldDelegate, PickupLocationViewDelegate> {

    UIView *loadingView;
    
    NSMutableArray *pickupResultsArray;
    
    UIView *lightGrayView;
    BOOL tableShown;
    
    NSDictionary *estimationsDictionary;
    
    BOOL luggage;
    BOOL quietRide;
    UIColor *selectedIconTintColor;
    UIColor *notSelectedIconTintColor;
    UIColor *selectedBGColor;
    UIColor *notSelectedBGColor;
    
    PickupLocationView *chooseLocationView;
}

@property (strong, nonatomic) NSMutableDictionary *rideParametersDictionary;
@property (strong, nonatomic) NSString *titleLabelString;

@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *myLocBtn;
- (IBAction)myLocationButton:(UIButton *)sender;

@property (strong, nonatomic) GMSPlacesClient *placesClient;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *PickupLocationLabel;
- (IBAction)choosePickupLocationBtnAction:(UIButton *)sender;

- (IBAction)backBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIView *luggageView;
@property (weak, nonatomic) IBOutlet UIImageView *luggageIcon;
@property (weak, nonatomic) IBOutlet UILabel *luggageLabel;
@property (weak, nonatomic) IBOutlet UIButton *luggageBtn;
- (IBAction)luggageBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *quietView;
@property (weak, nonatomic) IBOutlet UIImageView *quietIcon;
@property (weak, nonatomic) IBOutlet UILabel *quietLabel;
@property (weak, nonatomic) IBOutlet UIButton *quietBtn;
- (IBAction)quietRideBtnAction:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)confirmPickupAction:(UIButton *)sender;

@end

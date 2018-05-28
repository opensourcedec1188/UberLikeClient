//
//  OnRideViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 9/9/1438 AH.
//  Copyright © 1438 Ego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <NotificationCenter/NotificationCenter.h>

#import <PubNub/PubNub.h>

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>


//#import "RideClass.h"
#import "HelperClass.h"
#import "UIHelperClass.h"
#import "RidesServiceManager.h"
#import "UIImageView+AFNetworking.h"

#import "LocalNotification.h"
#import "PupnubRideManager.h"

#import "AcceptedRideFooterView.h"
#import "InitiatedRideFooterView.h"
#import "OnRideFooterView.h"
#import "LoadingCustomView.h"

@interface OnRideViewController : UIViewController <PupnubRideManagerDelegate, PNObjectEventListener, GMSMapViewDelegate, UNUserNotificationCenterDelegate, AcceptedRideFooterViewDelegate, InitiatedRideFooterViewDelegate, OnRideFooterViewDelegate> {
    UIView *loadingView;
    GMSMarker *driverMarker;
//    UILabel *etaLabel;
    
    //Pickup/DropOff Markers
    GMSMarker *dropOffMarker;
    GMSMarker *pickupMarker;
    
    GMSMutablePath *mainMapPath;
    GMSPolyline *mainMapPolyline;
    
    CLLocation *currentComingDriverLocation;
    
    BOOL footerShown;
    
    AcceptedRideFooterView *acceptedFooterView;
    InitiatedRideFooterView *initiatedFooterView;
    OnRideFooterView *onRideFooterView;
    
    NSArray *cancelationReasons;
}

@property (weak, nonatomic) IBOutlet UILabel *rideStatusLabel;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong) PupnubRideManager *pubnubManager;

@property (strong, nonatomic) NSDictionary *rideData;

@property (strong, nonatomic) NSDictionary *driverData;
@property (strong, nonatomic) NSDictionary *vehicleData;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerDestinationLabel;

#pragma mark - Accepted Ride Footer View
@property (weak, nonatomic) IBOutlet UIView *acceptedCancelView;
#pragma mark - On-Ride Footer View
@property (weak, nonatomic) IBOutlet UIView *onRideCancelView;

- (IBAction)myLocationButton:(UIButton *)sender;

@end

//
//  HomeViewController.h
//  Ego
//
//  Created by MacBookPro on 4/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>

#import "LoadingCustomView.h"

#import "HelperClass.h"
#import "UIHelperClass.h"
#import "RidesServiceManager.h"
#import "GoogleServicesManager.h"
#import "PickupConfirmationViewController.h"
#import "PupnubRideManager.h"

#import "RatingCustomView.h"
#import "DropOffLocationView.h"

#import "DownsideFavouritesView.h"
#import "SelectCategoryView.h"
//#import "NearbyRecentCardView.h"
#import "AddFavouriteViewController.h"

#import "NetworkErrorView.h"
#import "PaymentSelectView.h"

#import "MenuView.h"

#define STEPS_VIEWS_DISTANCE ((float) 10.0f)
#define STEPS_VIEWS_NORMAL_COMPRESS ((float) 5.0F)
#define STEPS_VIEWS_EXTRA_COMPRESS ((float) 5.0F)
#define ICONS_WIDTH ((float) 30.0F)
#define ICONS_HEIGHT ((float) 30.0F)

@interface HomeViewController : UIViewController <PupnubRideManagerDelegate, GMSMapViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, RatingCustomViewDelegate, DropOffLocationViewDelegate, MenuViewDelegate, NetworkErrorViewDelegate, DownsideFavouritesViewDelegate, SelectCategoryViewDelegate, PaymentSelectViewDelegate> {
    
    BOOL networkErrorShown;

    int selectedCategoryType;
    NSDictionary *estimationsDictionary;
    
    //Surround Drivers Work
    NSMutableArray *surroundDriversArray;
    
    //DropOff Markers
    GMSMarker *dropOffMarker;
    GMSMutablePath *mainMapPath;
    GMSPolyline *mainMapPolyline;
    
    LoadingCustomView *loadingView;
    
    RatingCustomView *ratingView;
    DropOffLocationView *chooseLocationView;
    
    NSString *stringFromShareExtension;
    
    BOOL fullCardsShown;
    int currentMode;
    NSMutableArray *favouritesArray;
    
    int currentFavIndex; //Currently shown favourites (favourites / nearby / recent)
    NSArray *nearByPlacesArray;
    NSArray *recentPlacesArray;
    
    BOOL menuShown;
    UITapGestureRecognizer *leftMenuBGGesture;
    
    NSString *selectedFavouriteToAdd;//Work-home-market-other
    
    NSArray *favouriteCoordinateForFavouritesFromDropoffView;
    
    PaymentSelectView *paymentView;
}
@property (strong, nonatomic) NetworkErrorView *networkErorView;

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBtmConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerRightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftManuSideConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downsideLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downsideRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downsideBtmConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmModeLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmModeRightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmModeBtnLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryIndicatorLeftConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *catBackBtnConst;


#pragma mark - Left Menu Button
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
- (IBAction)leftMenuBtnAction:(UIButton *)sender;
@property (strong, nonatomic) MenuView *leftMenuView;
@property (strong, nonatomic) UIView *leftMenuBG;

@property (weak, nonatomic) NSTimer *nearByDriversTimer;

@property (strong, nonatomic) NSMutableDictionary *rideParametersDictionary;

@property (nonatomic) PupnubRideManager *pupnubManager;

#pragma mark - MAP
@property (weak, nonatomic) IBOutlet UIButton *myLocBtn;
- (IBAction)myLocationButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;

#pragma mark - DropOff (Destination)
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (weak, nonatomic) IBOutlet UIButton *destinationButton;
@property (weak, nonatomic) IBOutlet UILabel *destinationAboveLabel;
- (IBAction)destinationButtonAction:(UIButton *)sender;

#pragma mark - Downside view
@property (weak, nonatomic) IBOutlet DownsideFavouritesView *downsideContainerView;

#pragma mark - VehicleCategory Select Mode
@property (weak, nonatomic) IBOutlet SelectCategoryView *confirmSelectModeView;
@property (weak, nonatomic) IBOutlet UIButton *confirmModeBackBtn;
- (IBAction)confirmModeBackBtnAction:(UIButton *)sender;


#pragma mark - Done button (For selecting location on map)
@property (weak, nonatomic) IBOutlet UIButton *mapBellowDoneButton;
- (IBAction)mapBellowDestinationLocationAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *mapBellowCancelBtn;
- (IBAction)mapBellowCancelBtnAction:(UIButton *)sender;


@end

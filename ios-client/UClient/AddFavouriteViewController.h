//
//  AddFavouriteViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <QuartzCore/QuartzCore.h>

#import "AddFavOnMapView.h"
#import "UIHelperClass.h"
#import "GoogleServicesManager.h"

@interface AddFavouriteViewController : UIViewController <GMSMapViewDelegate, AddFavOnMapViewDelegate> {
    AddFavOnMapView *chooseLocationView;
    UIView *loadingView;
}
@property (nonatomic, strong) NSString *favouriteToSet;
@property (nonatomic, strong) NSArray *locationArray;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UIButton *myLocBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)myLocBtnAction:(UIButton *)sender;

- (IBAction)showLocationViewAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitFavBtn;
- (IBAction)addFavouriteAction:(UIButton *)sender;

- (IBAction)backAction:(UIButton *)sender;
@end

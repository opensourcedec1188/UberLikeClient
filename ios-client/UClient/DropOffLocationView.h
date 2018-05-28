//
//  ChooseLocationView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/24/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>
#import <QuartzCore/QuartzCore.h>

#import "DefaultTableViewCell.h"
#import "RidesServiceManager.h"
#import "LoadingCustomView.h"
#import "UIHelperClass.h"

@protocol DropOffLocationViewDelegate <NSObject>
@required
-(void)setChosenLocation:(NSDictionary *)choosedLocation;
-(void)showLoading:(BOOL)show;
-(void)dismissView;
-(void)goToFavouritesControllerWithType:(NSString *)type andLocation:(NSArray *)locationCoordinate;
@end

@interface DropOffLocationView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DefaultTableViewCellDelegate, GMSAutocompleteFetcherDelegate> {
    LoadingCustomView *loadingView;
    
    NSArray *selectingOptions;
    NSMutableArray *resultsArray;
    int selectMode;
    IBOutlet DefaultTableViewCell *defaultCell;
    UITapGestureRecognizer *singleFingerTap;
    
    UIColor *selectedIconColor;
    UIColor *notSelectedIconColor;
    
    GMSAutocompletePrediction *placeToAddToFav;
}
@property (nonatomic, weak) id <DropOffLocationViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) GMSAutocompleteFetcher* fetcher;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *fieldContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
- (IBAction)closeBtnAction;

@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (weak, nonatomic) IBOutlet UIView *favouritesContainerView;

- (IBAction)favWorkAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *favWorkIcon;
- (IBAction)favHomeAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *favHomeIcon;
- (IBAction)favMarketAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *favMarketIcon;
- (IBAction)favOtherAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *favOtherIcon;

@end

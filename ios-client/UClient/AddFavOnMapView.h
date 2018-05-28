//
//  AddFavOnMapView.h
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>
#import <QuartzCore/QuartzCore.h>

#import "UIHelperClass.h"
#import "DefaultTableViewCell.h"
#import "RidesServiceManager.h"

@protocol AddFavOnMapViewDelegate <NSObject>
@required
-(void)setChosenLocation:(NSDictionary *)choosedLocation;
-(void)dismissView;
@end

@interface AddFavOnMapView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GMSAutocompleteFetcherDelegate> {
    NSMutableArray *resultsArray;
    IBOutlet DefaultTableViewCell *defaultCell;
}

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (nonatomic, weak) id <AddFavOnMapViewDelegate> delegate;

@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) GMSAutocompleteFetcher* fetcher;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *fieldContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
- (IBAction)closeBtnAction;

@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

-(void)hideMe;

@end

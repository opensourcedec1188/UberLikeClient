//
//  PickupLocationView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GMSGeocoder.h>
#import <QuartzCore/QuartzCore.h>

#import "DefaultTableViewCell.h"
#import "RidesServiceManager.h"
#import "UIHelperClass.h"

@protocol PickupLocationViewDelegate <NSObject>
@required
-(void)setChosenLocation:(NSDictionary *)choosedLocation;
-(void)dismissView;
@end

@interface PickupLocationView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GMSAutocompleteFetcherDelegate> {
    NSMutableArray *resultsArray;
    IBOutlet DefaultTableViewCell *defaultCell;
    
}

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (nonatomic, weak) id <PickupLocationViewDelegate> delegate;

@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) GMSAutocompleteFetcher* fetcher;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *fieldContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
- (IBAction)closeBtnAction;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;


@end

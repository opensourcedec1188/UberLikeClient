//
//  DownsideFavouritesView.h
//  Ego
//
//  Created by Mahmoud Amer on 9/17/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"

#import "NearbyRecentCardView.h"

@protocol DownsideFavouritesViewDelegate <NSObject>
@required
-(void)showFullDownsideView:(BOOL)show withHeight:(float)height;

-(void)setFavouriteAsDropOff:(int)selectedFavouriteIndex;
-(void)setNearByAsDropoff:(int)selectedIndex;
-(void)setRecentAsDropoff:(int)selectedIndex;
-(void)goToAddFavouritedWithKey:(int)key;
@end

@interface DownsideFavouritesView : UIView <NearbyRecentCardViewDelegate> {
    BOOL fullCardsShown;
    int currentFavIndex;
}

@property (nonatomic, weak) id <DownsideFavouritesViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

-(instancetype)initWithFrame:(CGRect)frame nearbyArray:(NSArray *)nearbyArray recentPlacesArray:(NSArray *)recentPlacesArray;

@property (nonatomic, strong) NSArray *favouritesArray;
@property (nonatomic, strong) NSArray *nearByPlacesArray;
@property (nonatomic, strong) NSArray *recentPlacesArray;

@property (weak, nonatomic) IBOutlet UIView *smallCardsContainerView;

@property (weak, nonatomic) IBOutlet UIScrollView *cardsScrollView;

@property (weak, nonatomic) IBOutlet UIView *favViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *favoutriteIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *downFavouriteLabel;
@property (weak, nonatomic) IBOutlet UIButton *showFavsBtn;
- (IBAction)showFavouritesAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *nearbyFavContainer;
@property (weak, nonatomic) IBOutlet UIImageView *downNearbyIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *downNearbyLabel;
@property (weak, nonatomic) IBOutlet UIButton *showNearbyBtn;
- (IBAction)showNearbyAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *recentViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *downRecentIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *downRecentLabel;
@property (weak, nonatomic) IBOutlet UIButton *showRecentBtn;
- (IBAction)showRecentAction:(UIButton *)sender;

@end

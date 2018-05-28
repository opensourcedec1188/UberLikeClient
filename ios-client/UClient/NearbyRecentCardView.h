//
//  NearbyRecentCardView.h
//  Ego
//
//  Created by Mahmoud Amer on 8/2/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NearbyRecentCardViewDelegate <NSObject>

@required
-(void)setFavouriteAsDropOff:(int)selectedFavouriteIndex;
-(void)setNearByAsDropoff:(int)selectedIndex;
-(void)setRecentAsDropoff:(int)selectedIndex;
-(void)goToAddFavouritedWithKey:(int)key;
@end

@interface NearbyRecentCardView : UIView {
    
}
@property (nonatomic, weak) id <NearbyRecentCardViewDelegate> delegate;
@property (nonatomic, strong) NSString *type;
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;
@property (weak, nonatomic) IBOutlet UIView *filledContentView;
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

- (IBAction)setSelectedAddress:(UIButton *)sender;

#pragma mark - Empty Content
@property (weak, nonatomic) IBOutlet UIView *emptyContentView;
@property (weak, nonatomic) IBOutlet UIView *dashedView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFavBtn;
- (IBAction)addButtonAction:(UIButton *)sender;

-(void)setEmpty;

@end

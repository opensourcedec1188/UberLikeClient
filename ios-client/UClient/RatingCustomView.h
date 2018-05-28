//
//  RatingCustomView.h
//  Ego
//
//  Created by Mahmoud Amer on 6/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "HelperClass.h"
#import "UIHelperClass.h"
#import "ServiceManager.h"
#import "RidesServiceManager.h"
#import "UIImageView+AFNetworking.h"

@protocol RatingCustomViewDelegate <NSObject>
@required
-(void)dismissRatingView:(BOOL)sucess;
@end

@interface RatingCustomView : UIView {
    int driverRating;
    NSDictionary *lastRideData;
    NSDictionary *clientData;
    NSDictionary *driverData;
    NSNumber *tip;
}

@property (nonatomic, weak) id <RatingCustomViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (weak, nonatomic) IBOutlet UIImageView *driverImageImgView;
@property (weak, nonatomic) IBOutlet UIView *ratingContainerView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *driverFirstBtn;
- (IBAction)driverFirstBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *driverSecondBtn;
- (IBAction)driverSecondBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *driverThirdBrn;
- (IBAction)driverThirdBrnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *driverForthBtn;
- (IBAction)driverForthBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *driverFifthBtn;
- (IBAction)driverFifthBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *noTipsBtn;
- (IBAction)noTipsBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *plusTwoBtn;
- (IBAction)plusTwoBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *plusFiveBtn;
- (IBAction)plusFiveBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *plusTenBtn;
- (IBAction)plusTenBtnAction:(UIButton *)sender;


- (IBAction)skipRatingAction:(UIButton *)sender;

- (IBAction)submitRatingAction:(UIButton *)sender;


@end

//
//  SelectCategoryView.h
//  Ego
//
//  Created by Mahmoud Amer on 9/17/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HelperClass.h"
#import "UIHelperClass.h"
#import "PaymentSelectView.h"

@protocol SelectCategoryViewDelegate <NSObject>
@required

-(void)convertToCategorySelectionMode:(BOOL)confirm;
-(void)reDrawDrivers:(int)currentCategory;
-(void)setSelectedCategory:(int)selectedCat;
-(void)goToConfirm;
-(void)showPaymentView;
@end

@interface SelectCategoryView : UIView <PaymentSelectViewDelegate> {
    int selectedCategoryType;
    
    PaymentSelectView *paymentView;
    
}

@property (nonatomic, weak) id <SelectCategoryViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryIndicatorLeftConstraint;

@property (nonatomic,strong) NSDictionary *estimationsDictionary;

#pragma mark - VehicleCategory Select Mode

@property (weak, nonatomic) IBOutlet UIView *firstCatView;
@property (weak, nonatomic) IBOutlet UIImageView *economyImgView;
@property (weak, nonatomic) IBOutlet UILabel *economyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *economyCostLabel;
- (IBAction)chooseEconomyAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *secondCatView;
@property (weak, nonatomic) IBOutlet UIImageView *familyImgView;
@property (weak, nonatomic) IBOutlet UILabel *familyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyCostLabel;
- (IBAction)chooseFamilyAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *thirdCatView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgView;
@property (weak, nonatomic) IBOutlet UILabel *vipTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipCostLabel;
- (IBAction)chooseVIPAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *categoryIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *etaLabel;

@property (weak, nonatomic) IBOutlet UIButton *paymentMainBtn;
- (IBAction)paymentMainBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *goToConfirmBtn;
- (IBAction)goToConfirmBtnAction:(UIButton *)sender;

-(void)displayEstimation;
-(void)resetEstimations;

-(void)moveCategoryIndicatorView:(int)selected;

@end

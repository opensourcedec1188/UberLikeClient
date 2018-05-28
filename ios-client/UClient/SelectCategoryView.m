//
//  SelectCategoryView.m
//  Ego
//
//  Created by Mahmoud Amer on 9/17/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

#import "SelectCategoryView.h"

@implementation SelectCategoryView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        [self customInit];
    }
    
    return self;
}

-(void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"SelectCategoryView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    UIBezierPath *goConfrmBtnShadowPath = [UIHelperClass setViewShadow:_goToConfirmBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _goToConfirmBtn.layer.shadowPath = goConfrmBtnShadowPath.CGPath;
    
    UIBezierPath *paymentBtnShadowPath = [UIHelperClass setViewShadow:_paymentMainBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _paymentMainBtn.layer.shadowPath = paymentBtnShadowPath.CGPath;
    
    UIBezierPath *categoryIndicatorShadowPath = [UIHelperClass setViewShadow:_categoryIndicatorView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _categoryIndicatorView.layer.shadowPath = categoryIndicatorShadowPath.CGPath;
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_firstCatView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _firstCatView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *secondCatShadowPath = [UIHelperClass setViewShadow:_secondCatView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _secondCatView.layer.shadowPath = secondCatShadowPath.CGPath;
    
    UIBezierPath *thirdCatShadowPath = [UIHelperClass setViewShadow:_thirdCatView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _thirdCatView.layer.shadowPath = thirdCatShadowPath.CGPath;
    
    _categoryIndicatorLeftConstraint.constant = _firstCatView.frame.origin.x;
    [self layoutIfNeeded];
    
}

-(void)displayEstimation{
    if(_estimationsDictionary){
        if([_estimationsDictionary objectForKey:@"economy"]){
            if([[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"ride"])
                _economyCostLabel.text = [NSString stringWithFormat:@"%@", [[[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"ride"] objectForKey:@"costDisplay"]];
        }
        if([_estimationsDictionary objectForKey:@"family"]){
            if([[_estimationsDictionary objectForKey:@"family"] objectForKey:@"ride"])
                _familyCostLabel.text = [NSString stringWithFormat:@"%@", [[[_estimationsDictionary objectForKey:@"family"] objectForKey:@"ride"] objectForKey:@"costDisplay"]];
        }
        if([_estimationsDictionary objectForKey:@"vip"]){
            if([[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"ride"])
                _vipCostLabel.text = [NSString stringWithFormat:@"%@", [[[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"ride"] objectForKey:@"costDisplay"]];
        }
        NSString *etaText;
        switch (selectedCategoryType) {
            case 1:
                if([[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"driver"])
                    etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"driver"] objectForKey:@"eta"]];
                else
                    etaText = @"-- min | 1x";
                break;
            case 2:
                if([[_estimationsDictionary objectForKey:@"family"] objectForKey:@"driver"])
                    etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"family"] objectForKey:@"driver"] objectForKey:@"eta"]];
                else
                    etaText = @"-- min | 1x";
                break;
            case 3:
                if([[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"driver"])
                    etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"driver"] objectForKey:@"eta"]];
                else
                    etaText = @"-- min | 1x";
                break;
                
            default:
                break;
        }
        _etaLabel.text = etaText;
    }
}

-(void)resetEstimations{
    _economyCostLabel.text = @"EGO Cost";
    
    _familyCostLabel.text = @"EGO-X Cost";
    
    _vipCostLabel.text = @"EGO-V CosCoste";
}

- (IBAction)chooseEconomyAction:(UIButton *)sender {
    [self moveCategoryIndicatorView:1];
}
- (IBAction)chooseFamilyAction:(UIButton *)sender {
    [self moveCategoryIndicatorView:2];
}
- (IBAction)chooseVIPAction:(UIButton *)sender {
    [self moveCategoryIndicatorView:3];
}

-(void)moveCategoryIndicatorView:(int)selected{
    selectedCategoryType = selected;
    [self.delegate setSelectedCategory:selected];
    [self.delegate reDrawDrivers:selectedCategoryType];
    
    float newCenterX = 0.0f;
    NSString *etaText = @"";
    switch (selected) {
        case 1:
            newCenterX = _firstCatView.center.x;
            if([[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"driver"])
                etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"economy"] objectForKey:@"driver"] objectForKey:@"eta"]];
            else
                etaText = @"- min | 1x";
            break;
        case 2:
            newCenterX = _secondCatView.center.x;
            if([[_estimationsDictionary objectForKey:@"family"] objectForKey:@"driver"])
                etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"family"] objectForKey:@"driver"] objectForKey:@"eta"]];
            else
                etaText = @"- min | 1x";
            break;
        case 3:
            newCenterX = _thirdCatView.center.x;
            if([[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"driver"])
                etaText = [NSString stringWithFormat:@"%@ min | 1X", [[[_estimationsDictionary objectForKey:@"vip"] objectForKey:@"driver"] objectForKey:@"eta"]];
            else
                etaText = @"- min | 1x";
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.2f
                          delay: 0.0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self setCategoriesNotSelectedExcept:selected];
                         _categoryIndicatorView.center = CGPointMake(newCenterX, _categoryIndicatorView.center.y);
                         _etaLabel.text = etaText;
                     }completion:^(BOOL finished){
                         
                     }];
    
}

-(void)setCategoriesNotSelectedExcept:(int)cat{
    _economyTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    _economyCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    [_economyImgView setImage:[UIImage imageNamed:@"economyNot.png"]];
    
    _familyTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    _familyCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    [_familyImgView setImage:[UIImage imageNamed:@"familyNot.png"]];
    
    _vipTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    _vipCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:0.4f];
    [_vipImgView setImage:[UIImage imageNamed:@"vipNot.png"]];
    
    switch (cat) {
        case 1:
            _economyTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            _economyCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            [_economyImgView setImage:[UIImage imageNamed:@"economySelected.png"]];
            break;
        case 2:
            _familyTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            _familyCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            [_familyImgView setImage:[UIImage imageNamed:@"familySelected.png"]];
            break;
        case 3:
            _vipTitleLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            _vipCostLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f];
            [_vipImgView setImage:[UIImage imageNamed:@"vipSelected.png"]];
            break;
            
        default:
            break;
    }
}

// Abdalla M. Magdy was here \m/(*_*)\m/

#pragma mark - Payment Work
- (IBAction)paymentMainBtnAction:(UIButton *)sender {
//    [paymentView removeFromSuperview];
//    paymentView = [[PaymentSelectView alloc] initWithFrame:self.superview.bounds];
//    paymentView.delegate = self;
//    [self.superview addSubview:paymentView];
    [self.delegate showPaymentView];
}

-(void)dismissPaymentView{
    [paymentView removeFromSuperview];
}

- (IBAction)confirmModeBackBtnAction:(UIButton *)sender {
    [self.delegate convertToCategorySelectionMode:NO];
}



#pragma mark - Finished Ride Params
- (IBAction)goToConfirmBtnAction:(UIButton *)sender {
    [self.delegate goToConfirm];
}

@end

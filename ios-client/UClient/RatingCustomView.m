//
//  RatingCustomView.m
//  Ego
//
//  Created by Mahmoud Amer on 6/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "RatingCustomView.h"

@interface RatingCustomView ()

@end

@implementation RatingCustomView

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
    [[NSBundle mainBundle] loadNibNamed:@"RatingCustomView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
        
    _ratingContainerView.layer.cornerRadius = _ratingContainerView.frame.size.height/2;
    _ratingContainerView.clipsToBounds = YES;
    
    _driverImageImgView.layer.cornerRadius = _driverImageImgView.frame.size.height/2;
    _driverImageImgView.clipsToBounds = YES;
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_driverImageImgView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:30.0f];
    _driverImageImgView.layer.shadowPath = shadowPath.CGPath;

    [self performSelectorInBackground:@selector(getLastRide) withObject:nil];
    tip = 0;
    driverRating = 0;
    [self setStars];
}


-(void)getLastRide{
    @autoreleasepool {
        [RidesServiceManager getRide:[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"lastRideId"] :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetLastRide:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetLastRide:(NSDictionary *)response{
    NSLog(@"finishGetLastRide : %@", response);
    if(response && [response objectForKey:@"data"]){
        if([response objectForKey:@"client"]){
            clientData = [response objectForKey:@"client"];
            [ServiceManager saveLoggedInClientData:clientData andAccessToken:nil];
        }
        if([response objectForKey:@"driver"]){
            driverData = [response objectForKey:@"driver"];
            [self displayDriverData];
        }
        if([response objectForKey:@"data"])
            lastRideData = [response objectForKey:@"data"];
        
    }else{
        [[self delegate] dismissRatingView:YES];
    }
}

-(void)displayDriverData{
    if(driverData && !([driverData isKindOfClass:[NSNull class]]) && ([driverData objectForKey:@"firstName"]) && ([driverData objectForKey:@"lastName"])){
        NSString *fName = [driverData objectForKey:@"firstName"];
        NSString *lName = [driverData objectForKey:@"lastName"];
        _driverNameLabel.text = [NSString stringWithFormat:@"%@ %@", fName, lName];
        
        NSString *driverPhotoURL = [driverData objectForKey:@"photoUrl"];
        [_driverImageImgView setImageWithURL:[NSURL URLWithString:driverPhotoURL] placeholderImage:[UIImage imageNamed:@"person"]];
        _driverImageImgView.layer.cornerRadius = _driverImageImgView.frame.size.height/2;
        _driverImageImgView.clipsToBounds = YES;
        _driverImageImgView.layer.borderColor = [UIColor whiteColor].CGColor;
        _driverImageImgView.layer.borderWidth = 1.0f;
        if([driverData objectForKey:@"ratingsAvg"])
            _ratingLabel.text = [NSString stringWithFormat:@"%.2f", [[driverData objectForKey:@"ratingsAvg"] floatValue]];
        
        UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_driverImageImgView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:30.0f];
        _driverImageImgView.layer.shadowPath = shadowPath.CGPath;
    }
}

#pragma mark - Driver Rating
- (IBAction)driverFirstBtnAction:(UIButton *)sender {
    driverRating = 1;
    [self setStars];
}

- (IBAction)driverSecondBtnAction:(UIButton *)sender {
    driverRating = 2;
    [self setStars];
}

- (IBAction)driverThirdBrnAction:(UIButton *)sender {
    driverRating = 3;
    [self setStars];
}

- (IBAction)driverForthBtnAction:(UIButton *)sender {
    driverRating = 4;
    [self setStars];
}

- (IBAction)driverFifthBtnAction:(UIButton *)sender {
    driverRating = 5;
    [self setStars];
}

-(void)setStars{
    switch (driverRating) {
        case 0:
            [self setStarInActive:_driverFirstBtn];
            [self setStarInActive:_driverSecondBtn];
            [self setStarInActive:_driverThirdBrn];
            [self setStarInActive:_driverForthBtn];
            [self setStarInActive:_driverFifthBtn];
            break;
        case 1:
            [self setStarAction:_driverFirstBtn];
            [self setStarInActive:_driverSecondBtn];
            [self setStarInActive:_driverThirdBrn];
            [self setStarInActive:_driverForthBtn];
            [self setStarInActive:_driverFifthBtn];
            break;
        case 2:
            [self setStarAction:_driverFirstBtn];
            [self setStarAction:_driverSecondBtn];
            [self setStarInActive:_driverThirdBrn];
            [self setStarInActive:_driverForthBtn];
            [self setStarInActive:_driverFifthBtn];
            break;
        case 3:
            [self setStarAction:_driverFirstBtn];
            [self setStarAction:_driverSecondBtn];
            [self setStarAction:_driverThirdBrn];
            [self setStarInActive:_driverForthBtn];
            [self setStarInActive:_driverFifthBtn];
            break;
        case 4:
            [self setStarAction:_driverFirstBtn];
            [self setStarAction:_driverSecondBtn];
            [self setStarAction:_driverThirdBrn];
            [self setStarAction:_driverForthBtn];
            [self setStarInActive:_driverFifthBtn];
            break;
        case 5:
            [self setStarAction:_driverFirstBtn];
            [self setStarAction:_driverSecondBtn];
            [self setStarAction:_driverThirdBrn];
            [self setStarAction:_driverForthBtn];
            [self setStarAction:_driverFifthBtn];
            break;
            
        default:
            break;
    }
}

-(void)setStarAction:(UIButton *)button{
    [button setTintColor:[UIColor colorWithRed:249/255.0 green:205/255.0 blue:65/255.0 alpha:1.0f]];
}

-(void)setStarInActive:(UIButton *)button{
    [button setTintColor:[UIColor colorWithRed:230/255.0 green:231/255.0 blue:232/255.0 alpha:1.0f]];
}

- (IBAction)noTipsBtnAction:(UIButton *)sender{
    tip = 0;
    [self setSelectedBtn:_noTipsBtn];
    [self setNotSelectedTipsBtn:_plusTwoBtn];
    [self setNotSelectedTipsBtn:_plusFiveBtn];
    [self setNotSelectedTipsBtn:_plusTenBtn];
}
- (IBAction)plusTwoBtnAction:(UIButton *)sender {
    tip = [NSNumber numberWithInt:2];
    [self setSelectedBtn:_plusTwoBtn];
    [self setNotSelectedTipsBtn:_noTipsBtn];
    [self setNotSelectedTipsBtn:_plusFiveBtn];
    [self setNotSelectedTipsBtn:_plusTenBtn];
}

- (IBAction)plusFiveBtnAction:(UIButton *)sender {
    tip = [NSNumber numberWithInt:5];
    [self setSelectedBtn:_plusFiveBtn];
    [self setNotSelectedTipsBtn:_noTipsBtn];
    [self setNotSelectedTipsBtn:_plusTwoBtn];
    [self setNotSelectedTipsBtn:_plusTenBtn];
}

- (IBAction)plusTenBtnAction:(UIButton *)sender {
    tip = [NSNumber numberWithInt:10];
    [self setSelectedBtn:_plusTenBtn];
    [self setNotSelectedTipsBtn:_noTipsBtn];
    [self setNotSelectedTipsBtn:_plusTwoBtn];
    [self setNotSelectedTipsBtn:_plusFiveBtn];
}

-(void)setSelectedBtn:(UIButton *)button{
    button.backgroundColor = [UIColor colorWithRed:0/255.0 green:172/255.0 blue:250/255.0 alpha:1.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
-(void)setNotSelectedTipsBtn:(UIButton *)button{
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor colorWithRed:0/255.0 green:172/255.0 blue:250/255.0 alpha:1.0f] forState:UIControlStateNormal];
}

#pragma mark - Rating request
-(void)rateInBG{
    NSString *driverRatingString;
    if(driverRating == 0)
        driverRatingString = @"-1";
    else
        driverRatingString = [NSString stringWithFormat:@"%i", driverRating];
    
    @autoreleasepool {
        NSDictionary *ratingRequestParameters = @{
                                                  @"rating" : driverRatingString,
                                                  @"tip" : [NSString stringWithFormat:@"%i", [tip intValue]]
                                                  };
        
        [RidesServiceManager rateVehicleAndDriver:ratingRequestParameters forRideID:[lastRideData objectForKey:@"_id"] :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishRateInBg:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishRateInBg:(NSDictionary *)response{
    NSLog(@"rateing response : %@", response);
    if(response && ([response objectForKey:@"data"])){
        if([response objectForKey:@"client"]){
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"client"] andAccessToken:nil];
        }
        [[self delegate] dismissRatingView:YES];
    }else{
        [[self delegate] dismissRatingView:NO];
    }
}




#pragma mark - Skip Rating Action
- (IBAction)skipRatingAction:(UIButton *)sender {
    driverRating = 0;
    [self performSelectorInBackground:@selector(rateInBG) withObject:nil];
}

- (IBAction)submitRatingAction:(UIButton *)sender {
    [self performSelectorInBackground:@selector(rateInBG) withObject:nil];
}

@end

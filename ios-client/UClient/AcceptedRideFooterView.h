//
//  AcceptedRideFooterView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIHelperClass.h"

@protocol AcceptedRideFooterViewDelegate <NSObject>
@required
-(void)cancelAction;
-(void)callDriverPhone;
@end

@interface AcceptedRideFooterView : UIView {
    UIPanGestureRecognizer *acceptedFooterPanGesture;
    float initialYAfterPan;
    float finalYAfterPan;
    float initialY;
}

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (nonatomic, weak) id <AcceptedRideFooterViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *windowView;
#pragma mark - Accepted Ride Footer View
@property (strong, nonatomic) UIView *initialCancelConfirmBGView;

@property (weak, nonatomic) IBOutlet UIView *acceptedCencelConfirmationView;

@property (weak, nonatomic) IBOutlet UIImageView *acceptedDriverImageView;
@property (weak, nonatomic) IBOutlet UILabel *acceptedDriverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accceptedDriverRateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *acceptedVehicleImageView;
@property (weak, nonatomic) IBOutlet UILabel *acceptedVehicleLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptedVehicleNumLabel;

- (IBAction)acceptedCancelAction:(UIButton *)sender;
- (IBAction)confirmAcceptedCancelButtonAction:(UIButton *)sender;
- (IBAction)notConfirmAcceptedCancelBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *callBtn;
- (IBAction)callBtnAction:(UIButton *)sender;
@end

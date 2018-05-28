//
//  ForgetPasswordOTPViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 7/30/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTextField.h"
#import "HelperClass.h"
#import "ServiceManager.h"

#import "ResetPasswordViewController.h"

@interface ForgetPasswordOTPViewController : UIViewController <CustomTextFieldDelegate> {
    UIView *loadingView;
    NSString *userInsertedCode;
}


@property NSUInteger counter;
@property (nonatomic, strong) NSTimer *timer;

@property (strong, nonatomic) NSString *mobileNumber;

@property (weak, nonatomic) IBOutlet CustomTextField *firstDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *secondDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *thirdDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *forthDigitTF;

@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *resendOTPButton;

- (IBAction)resendOTPAction:(UIButton *)sender;

- (IBAction)backAction:(UIButton *)sender;


@end

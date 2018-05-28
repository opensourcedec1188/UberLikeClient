//
//  ResetPasswordViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 7/30/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"


@interface ResetPasswordViewController : UIViewController{
    UIView *loadingView;
}
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *passwSubview;
@property (weak, nonatomic) IBOutlet UIView *confirmSubview;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTop;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
- (IBAction)showPasswordAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmTop;
- (IBAction)showConfirmPasswordAction:(UIButton *)sender;

- (IBAction)resetPasswordAction:(UIButton *)sender;
- (IBAction)backAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@end

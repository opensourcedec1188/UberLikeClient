//
//  PasswordViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"

#import "ForgetPasswordOTPViewController.h"

@interface PasswordViewController : UIViewController {
    UIView *loadingView;
    
    
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIView *passwordSubview;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) NSString *mobileNumber;

- (IBAction)goAction:(UIButton *)sender;
- (IBAction)forgetPasswordAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;
- (IBAction)backAction:(UIButton *)sender;
@end

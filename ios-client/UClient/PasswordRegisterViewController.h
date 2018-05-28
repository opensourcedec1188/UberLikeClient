//
//  PasswordRegisterViewController.h
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
#import "ClientSideValidation.h"

@protocol PasswordRegisterViewControllerDelegate <NSObject>
@required
-(void)backToRegisterController;
-(void)showRootLoadingView;
-(void)hideRootLoadingView;

-(void)moveViewForTextFields:(float)newY andShow:(BOOL)show;
@end

@interface PasswordRegisterViewController : UIViewController {
    
}

@property (nonatomic, weak) id<PasswordRegisterViewControllerDelegate> delegate;


@property (nonatomic, strong) NSMutableDictionary *requestParameters;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTop;
@property (weak, nonatomic) IBOutlet UIView *passwordSubview;
- (IBAction)showPasswordAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTF;
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmTop;
- (IBAction)showConfirmPasswordAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *confirmSubview;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *goBtn;
- (IBAction)finishRegistrationAction:(UIButton *)sender;
@end

//
//  RegisterViewController.h
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"
#import "ClientSideValidation.h"

@protocol FullRegisterViewControllerDelegate <NSObject>
@required
-(void)moveToPasswordRegistration:(NSDictionary *)requestParams;
-(void)backToConfirmMobileController;
-(void)showRootLoadingView;
-(void)hideRootLoadingView;

-(void)moveViewForTextFields:(float)newY andShow:(BOOL)show;
@end


@interface RegisterViewController : UIViewController <UITextFieldDelegate> {

}

@property (nonatomic, weak) id<FullRegisterViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *requestParameters;

@property (weak, nonatomic) IBOutlet UITextField *fNameTF;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstNameTop;
@property (weak, nonatomic) IBOutlet UIView *fNameSubview;
@property (weak, nonatomic) IBOutlet UITextField *sNameTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snameTop;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UIView *sNameSubview;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTop;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *emailSubview;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *goBtn;
- (IBAction)continueRegistration:(UIButton *)sender;
@end

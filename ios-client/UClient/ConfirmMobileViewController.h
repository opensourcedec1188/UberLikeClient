//
//  ConfirmMobileViewController.h
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTextField.h"

#import "ServiceManager.h"
#import "HelperClass.h"

@protocol ConfirmMobileViewControllerDelegate <NSObject>
@required
-(void)moveToRegisterController:(NSDictionary *)requestParams;
-(void)backToEnterMobileController;
-(void)showRootLoadingView;
-(void)hideRootLoadingView;
@end

@interface ConfirmMobileViewController : UIViewController <UITextInputDelegate, UITextFieldDelegate, CustomTextFieldDelegate> {
    NSString *userInsertedCode;

}
@property NSUInteger counter;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) id<ConfirmMobileViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *requestParameters;

@property (weak, nonatomic) IBOutlet CustomTextField *firstDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *secondDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *thirdDigitTF;
@property (weak, nonatomic) IBOutlet CustomTextField *forthDigitTF;

@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *resendOTPButton;

- (IBAction)resendOTPAction:(UIButton *)sender;
@end

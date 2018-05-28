//
//  MobileNumberViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServiceManager.h"
#import "HelperClass.h"

#import "PasswordViewController.h"
#import "RegisterRootViewController.h"
#import "UIHelperClass.h"

@interface MobileNumberViewController : UIViewController {
    UIView *loadingView;
    
    NSString *mobileNumberEnglish;
    NSDictionary *parametersForRegistration;
}

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UIView *mobileSubView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *goBtn;
- (IBAction)goAction:(UIButton *)sender;

@end

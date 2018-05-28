//
//  PaymentViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 8/5/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "ProfileServiceManager.h"
#import "UIHelperClass.h"

@interface PaymentViewController : UIViewController {
    UIView *loadingView;
    NSDictionary *clientData;
}
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *walletCreditLabel;

@property (weak, nonatomic) IBOutlet UISwitch *walletSwitch;
- (IBAction)useWalletSwitchAction:(UISwitch *)sender;

- (IBAction)backAction:(UIButton *)sender;
@end

//
//  RegisterRootViewController.h
//  Ego
//
//  Created by MacBookPro on 2/28/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfirmMobileViewController.h"
#import "RegisterViewController.h"
#import "PasswordRegisterViewController.h"


@interface RegisterRootViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ConfirmMobileViewControllerDelegate, FullRegisterViewControllerDelegate, PasswordRegisterViewControllerDelegate> {
    NSArray *myViewControllers;
    NSUInteger pageIndex;
    UIView *loadingView;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (strong, nonatomic) NSString *mobileNumber;
@property (weak, nonatomic) NSDictionary *requestParameters;

- (IBAction)backAction:(UIButton *)sender;
@end

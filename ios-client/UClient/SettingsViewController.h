//
//  SettingsViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 8/5/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"
#import "UIImageView+AFNetworking.h"

#import "AddFavouriteViewController.h"


@interface SettingsViewController : UIViewController {
    NSDictionary *clientData;
    BOOL favShown;

    NSString *selectedFavouriteToAdd;
    
}

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *clientBGView;
@property (weak, nonatomic) IBOutlet UIImageView *clientImageView;
@property (weak, nonatomic) IBOutlet UILabel *raingLabel;

@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;
- (IBAction)editFavouritesAction:(UIButton *)sender;
- (IBAction)bacomeDriverAction:(UIButton *)sender;
- (IBAction)legalAction:(UIButton *)sender;
- (IBAction)privacySettingsAction:(UIButton *)sender;
- (IBAction)signoutAction:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UILabel *homeAddLabel;
@property (weak, nonatomic) IBOutlet UILabel *workAddLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketAddLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherAddLabel;

@property (weak, nonatomic) IBOutlet UIView *favouritesContainerView;
- (IBAction)editHomeAction:(UIButton *)sender;
- (IBAction)editWorkAction:(UIButton *)sender;
- (IBAction)editMarketAction:(UIButton *)sender;
- (IBAction)editOtherAction:(UIButton *)sender;


- (IBAction)backAction:(UIButton *)sender;
@end

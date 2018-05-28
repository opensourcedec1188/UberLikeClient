//
//  SecondLevelHelpViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "ProfileServiceManager.h"
#import "CancelationReasonsTableViewCell.h"
#import "SecondLevelHelpViewController.h"
#import "SubmitHelpRequestViewController.h"
#import "UIHelperClass.h"


@interface SecondLevelHelpViewController : UIViewController <UINavigationControllerDelegate> {
    IBOutlet CancelationReasonsTableViewCell *defaultCell;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray *optionArray;
@property (nonatomic, strong) NSString *rideID;
@property (weak, nonatomic) IBOutlet UITableView *helpTableView;

- (IBAction)backBtnAction:(UIButton *)sender;
@end

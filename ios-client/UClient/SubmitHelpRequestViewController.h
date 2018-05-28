//
//  SubmitHelpRequestViewController.h
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitHelpRequestViewController : UIViewController

@property (nonatomic, strong) NSDictionary *requestData;
@property (nonatomic, strong) NSString *rideID;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *testIDLabel;

- (IBAction)backAction:(UIButton *)sender;
@end

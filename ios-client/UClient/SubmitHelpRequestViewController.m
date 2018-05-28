//
//  SubmitHelpRequestViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "SubmitHelpRequestViewController.h"

@interface SubmitHelpRequestViewController ()

@end

@implementation SubmitHelpRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"going to report ride : %@", _rideID);
    _valueLabel.text = [_requestData objectForKey:@"label"];
    _testIDLabel.text = _rideID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(UIButton *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

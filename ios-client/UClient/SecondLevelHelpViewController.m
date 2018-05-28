//
//  SecondLevelHelpViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "SecondLevelHelpViewController.h"

@interface SecondLevelHelpViewController ()

@end

@implementation SecondLevelHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SecondLevelHelpViewController with rideID : %@", _rideID);
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_helpTableView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _helpTableView.layer.shadowPath = shadowPath.CGPath;
    
    if(_optionArray.count > 0)
        [_helpTableView reloadData];
    else {
        if(_rideID){
            [self performSelectorInBackground:@selector(getRideHelpOptions) withObject:nil];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_rideID.length > 0)
        _titleLabel.text = NSLocalizedString(@"report_trip", @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Help Options Request
-(void)getRideHelpOptions{
    @autoreleasepool {
        [ProfileServiceManager getRideHelpOptions:^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetRideOptions:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetRideOptions:(NSDictionary *)response{
    if(response){
        if([response objectForKey:@"data"]){
            _optionArray = [response objectForKey:@"data"];
            [_helpTableView reloadData];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_optionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"defaultcell";
    CancelationReasonsTableViewCell *cell = (CancelationReasonsTableViewCell *)[_helpTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CancelationReasonsTableViewCell" owner:self options:nil];
        cell = defaultCell;
    }
    if(indexPath.row == (_optionArray.count - 1))
        [cell.separatorView setHidden:YES];
    cell.reasonLabel.text = [[_optionArray objectAtIndex:indexPath.row] objectForKey:@"label"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_optionArray objectAtIndex:indexPath.row] objectForKey:@"subitems"]){
        SecondLevelHelpViewController *controller = [[SecondLevelHelpViewController alloc] init];
        controller.optionArray = [[_optionArray objectAtIndex:indexPath.row] objectForKey:@"subitems"];
        if(_rideID && (_rideID.length > 0))
            controller.rideID = _rideID;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        SubmitHelpRequestViewController *controller = [[SubmitHelpRequestViewController alloc] init];
        controller.requestData = [_optionArray objectAtIndex:indexPath.row];
        if(_rideID && (_rideID.length > 0))
            controller.rideID = _rideID;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)backBtnAction:(UIButton *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

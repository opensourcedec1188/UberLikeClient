//
//  HelpViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "HelpViewController.h"
#import "AppDelegate.h"

@interface HelpViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"CancelationReasonsTableViewCell" bundle:nil];
    [_helpTableView registerNib:cellNib forCellReuseIdentifier:@"defaultCell"];
        
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_mainView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _mainView.layer.shadowPath = shadowPath.CGPath;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self performSelectorInBackground:@selector(getGeneralHelpOptions) withObject:nil];
    
    [self performSelectorInBackground:@selector(getRideHelpOptions) withObject:nil];
}

#pragma mark - If no general help options, get it
#pragma mark - Get General Help Options
-(void)getGeneralHelpOptions{
    @autoreleasepool {
        [ProfileServiceManager getGeneralHelpOptions:^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetGeneralHelpOptions:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetGeneralHelpOptions:(NSDictionary *)response{
    if(response){
        if([response objectForKey:@"data"]){
            helpOptionsArray = [response objectForKey:@"data"];
            [_helpTableView reloadData];
        }
    }
}

#pragma mark - If not ride help options, Get it
#pragma mark - Get Ride Help Options
-(void)getRideHelpOptions{
    @autoreleasepool {
        [ProfileServiceManager getRideHelpOptions:^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetRideHelpOptions:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetRideHelpOptions:(NSDictionary *)response{
    if(response){
        if([response objectForKey:@"data"]){
            rideHelpOptions = [response objectForKey:@"data"];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [helpOptionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"defaultcell";
    CancelationReasonsTableViewCell *cell = (CancelationReasonsTableViewCell *)[_helpTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CancelationReasonsTableViewCell" owner:self options:nil];
        cell = defaultCell;
    }
    
    cell.reasonLabel.text = [[helpOptionsArray objectAtIndex:indexPath.row] objectForKey:@"label"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[helpOptionsArray objectAtIndex:indexPath.row] objectForKey:@"subitems"]){
        SecondLevelHelpViewController *controller = [[SecondLevelHelpViewController alloc] init];
        controller.optionArray = [[helpOptionsArray objectAtIndex:indexPath.row] objectForKey:@"subitems"];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        SubmitHelpRequestViewController *controller = [[SubmitHelpRequestViewController alloc] init];
        controller.requestData = [helpOptionsArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)backBtnAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

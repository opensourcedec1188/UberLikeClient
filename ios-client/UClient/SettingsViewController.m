//
//  SettingsViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/5/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    clientData = [ServiceManager getClientDataFromUserDefaults];
    _clientImageView.layer.cornerRadius = _clientImageView.frame.size.height/2;
    _clientBGView.layer.cornerRadius = _clientBGView.frame.size.height/2;
    _clientBGView.clipsToBounds = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"clientImageData"])
        [_clientImageView setImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"clientImageData"]]];
    else{
        NSString *clientPhotoURL = [clientData objectForKey:@"photoUrl"];
        [_clientImageView setImageWithURL:[NSURL URLWithString:clientPhotoURL] placeholderImage:[UIImage imageNamed:@"driver_placeholder.png"]];
    }
    _clientImageView.layer.masksToBounds = YES;
    _raingLabel.text = [NSString stringWithFormat:@"%.2f", [[clientData objectForKey:@"ratingsAvg"] floatValue]];
    
    _favouritesContainerView.frame = CGRectMake(self.view.frame.size.width, _favouritesContainerView.frame.origin.y, _favouritesContainerView.frame.size.width, _favouritesContainerView.frame.size.height);
    favShown = NO;
    
    [self displayAddresses];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_mainView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _mainView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *clientImgShadowPath = [UIHelperClass setViewShadow:_clientBGView edgeInset:UIEdgeInsetsMake(-5.0f, -5.0f, -5.0f, -5.0f) andShadowRadius:_clientBGView.frame.size.height/2];
    _clientBGView.layer.shadowPath = clientImgShadowPath.CGPath;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showFavView:NO];
}

-(void)displayAddresses{
    NSString *addKey = @"";
    if([[HelperClass getDeviceLanguage] isEqualToString:@"ar"])
        addKey = @"arabicAddress";
    else
        addKey = @"englishAddress";
    
    if([clientData objectForKey:@"home"]){
        if([[clientData objectForKey:@"home"] objectForKey:addKey])
            _homeAddLabel.text = [[clientData objectForKey:@"home"] objectForKey:addKey];
    }
    if([clientData objectForKey:@"work"]){
        if([[clientData objectForKey:@"work"] objectForKey:addKey])
            _workAddLabel.text = [[clientData objectForKey:@"work"] objectForKey:addKey];
    }
    if([clientData objectForKey:@"market"]){
        if([[clientData objectForKey:@"market"] objectForKey:addKey])
            _marketAddLabel.text = [[clientData objectForKey:@"market"] objectForKey:addKey];
    }
    if([clientData objectForKey:@"other"]){
        if([[clientData objectForKey:@"other"] objectForKey:addKey])
            _otherAddLabel.text = [[clientData objectForKey:@"other"] objectForKey:addKey];
    }
    
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)editFavouritesAction:(UIButton *)sender {
    [self showFavView:YES];
}


#pragma mark - Settings Main Actions
- (IBAction)bacomeDriverAction:(UIButton *)sender {
    
}

- (IBAction)legalAction:(UIButton *)sender{
    
}

- (IBAction)privacySettingsAction:(UIButton *)sender{
    
}

- (IBAction)signoutAction:(UIButton *)sender{
    [self performSelectorInBackground:@selector(SMLogout) withObject:nil];
}

#pragma mark - Favorites Actions
- (IBAction)editHomeAction:(UIButton *)sender {
    [self goToAddFavouritedWithKey:0];
    
}

- (IBAction)editWorkAction:(UIButton *)sender {
    [self goToAddFavouritedWithKey:1];
    
}

- (IBAction)editMarketAction:(UIButton *)sender {
    [self goToAddFavouritedWithKey:2];
}

- (IBAction)editOtherAction:(UIButton *)sender {
    [self goToAddFavouritedWithKey:3];
}

- (IBAction)backAction:(UIButton *)sender {
    if(favShown)
        [self showFavView:NO];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Go Edit Favourites
-(void)showFavView:(BOOL)show{
    favShown = show;
    if(show){
        [UIView animateWithDuration:0.3f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _favouritesContainerView.frame = CGRectMake(0, _favouritesContainerView.frame.origin.y, _favouritesContainerView.frame.size.width, _favouritesContainerView.frame.size.height);
                             _settingsContainerView.frame = CGRectMake(-_settingsContainerView.frame.size.width, _settingsContainerView.frame.origin.y, _settingsContainerView.frame.size.width, _settingsContainerView.frame.size.height);
                         } completion:^(BOOL finished){}];
    }else{
        [UIView animateWithDuration:0.3f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _favouritesContainerView.frame = CGRectMake(_favouritesContainerView.frame.size.width, _favouritesContainerView.frame.origin.y, _favouritesContainerView.frame.size.width, _favouritesContainerView.frame.size.height);
                             _settingsContainerView.frame = CGRectMake(0, _settingsContainerView.frame.origin.y, _settingsContainerView.frame.size.width, _settingsContainerView.frame.size.height);
                         } completion:^(BOOL finished){}];
    }
}

-(void)goToAddFavouritedWithKey:(int)key{
    switch (key) {
        case 0:
            selectedFavouriteToAdd = @"home";
            break;
        case 1:
            selectedFavouriteToAdd = @"work";
            break;
        case 2:
            selectedFavouriteToAdd = @"market";
            break;
        case 3:
            selectedFavouriteToAdd = @"other";
            break;
        default:
            break;
    }
//    [self performSegueWithIdentifier:@"settingsEditFavourites" sender:self];
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddFavouriteViewController *addFavController = (AddFavouriteViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"AddFavController"];
    addFavController.favouriteToSet = selectedFavouriteToAdd;
    [self presentViewController:addFavController animated:YES completion:nil];
}

#pragma mark - Logout
#pragma mark - Logout
-(void)SMLogout
{
    @autoreleasepool {
        [ServiceManager clientLogout :^(NSDictionary *logoutData) {
            [self performSelectorOnMainThread:@selector(finishLogoutRequest:) withObject:logoutData waitUntilDone:NO];
        }];
    }
}

-(void)finishLogoutRequest:(NSDictionary *)logoutData
{
    if(logoutData){
        NSLog(@"logout successful with data %@", logoutData);
        BOOL clientDeleted = [ServiceManager deleteLoggedInClientDataFromDevice];
        if(clientDeleted){
//            [self performSegueWithIdentifier:@"logoutSegue" sender:self];
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"PreLogin" bundle:nil];
            UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
            [self presentViewController:theInitialViewController animated:YES completion:nil];
        }
    }else{
        /* logout failed  */
        
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"settingsEditFavourites"]) {
        AddFavouriteViewController *addFavController = [segue destinationViewController];
        addFavController.favouriteToSet = selectedFavouriteToAdd;
    }
}

@end

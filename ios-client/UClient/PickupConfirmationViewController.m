//
//  PickupConfirmationViewController.m
//  Ego
//
//  Created by MacBookPro on 4/29/17.
//  Copyright © 2017 Procab. All rights reserved.
//

#import "PickupConfirmationViewController.h"
#import "AppDelegate.h"

@import UserNotifications;

@interface PickupConfirmationViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@end

@implementation PickupConfirmationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutSubviews];
    _applicationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"pickup confirm with params : %@", _rideParametersDictionary);
    [_confirmButton setTitle:NSLocalizedString(@"PCC_confirm_btn_title", @"") forState:UIControlStateNormal];
    
    selectedIconTintColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    selectedBGColor = [UIColor colorWithRed:0.0/255 green:172.0/255 blue:250.0/255 alpha:1.0];
    
    notSelectedIconTintColor = [UIColor colorWithRed:34.0/255 green:50.0/255 blue:73.0/255 alpha:1.0];
    notSelectedBGColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    
    //Get Address With Estimation
    [GoogleServicesManager getAddressFromCoordinates:_applicationDelegate.currentLocation.coordinate.latitude andLong:_applicationDelegate.currentLocation.coordinate.longitude :^(NSDictionary *response){
        
        NSArray *pickupArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.longitude], nil];
        NSDictionary *pickupLocDict = @{@"coordinates" : pickupArray, @"type" : @"Point"};
        [_rideParametersDictionary setObject:pickupLocDict forKey:@"pickupLocation"];
        _PickupLocationLabel.text = [response objectForKey:@"address"];
        
    }];
    luggage = NO;
    quietRide = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    _placesClient = [GMSPlacesClient sharedClient];
    
    [self updateMapToCam];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_headerView edgeInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) andShadowRadius:25.0f];
    _headerView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *btnShadowPath = [UIHelperClass setViewShadow:_confirmButton edgeInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) andShadowRadius:5.0f];
    _confirmButton.layer.shadowPath = btnShadowPath.CGPath;
    
    //Adjusting Pin Selection Frame
    _pinImageView.frame = CGRectMake((self.view.frame.size.width/2) - (_pinImageView.frame.size.width/2), (self.view.frame.size.height/2) - (_pinImageView.frame.size.height), _pinImageView.frame.size.width, _pinImageView.frame.size.height);
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"lastRideMessage"] isEqualToString:@"not-rated"])
        [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    _mapView.myLocationEnabled = NO;
}



-(void)updateMapToCam{
    GMSCameraPosition *mapCamera = [GMSCameraPosition cameraWithLatitude:self.applicationDelegate.currentLocation.coordinate.latitude
                                          longitude:self.applicationDelegate.currentLocation.coordinate.longitude
                                               zoom:18];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [_mapView setCamera:mapCamera];
    //Map Style
    GMSMapStyle *style = [RidesServiceManager setMapStyleFromFileName:@"style"];
    if(style)
        [_mapView setMapStyle:style];
}

- (IBAction)myLocationButton:(UIButton *)sender {
    CLLocation *location = _mapView.myLocation;
    if (location) {
        [_mapView animateToLocation:location.coordinate];
    }
}

#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
}

#pragma - mark Mapview Delegate

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    _PickupLocationLabel.text = NSLocalizedString(@"loading", @"");
    [GoogleServicesManager getAddressFromCoordinates:mapView.camera.target.latitude andLong:mapView.camera.target.longitude :^(NSDictionary *response){
        
        NSLog(@"Map Idle : %@ ", [response objectForKey:@"address"]);
        
        NSArray *pickupArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", mapView.camera.target.latitude], [NSString stringWithFormat:@"%f", mapView.camera.target.longitude], nil];
        NSDictionary *pickupLocDict = @{@"coordinates" : pickupArray, @"type" : @"Point"};
        [_rideParametersDictionary setObject:pickupLocDict forKey:@"pickupLocation"];
        _PickupLocationLabel.text = [response objectForKey:@"address"];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Request new ride

- (IBAction)confirmPickupAction:(UIButton *)sender {
    [self prepareRideRequest];
}

-(void)prepareRideRequest{
    NSArray *currentLocationLocationArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _mapView.camera.target.latitude], [NSString stringWithFormat:@"%f", _mapView.camera.target.longitude], nil];
    NSDictionary *currentLoc = @{@"coordinates" : currentLocationLocationArray, @"type" : @"Point"};
    [_rideParametersDictionary setObject:currentLoc forKey:@"currentLocation"];
    
    NSArray *pickupArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _mapView.camera.target.latitude], [NSString stringWithFormat:@"%f", _mapView.camera.target.longitude], nil];
    NSDictionary *pickupLocDict = @{@"coordinates" : pickupArray, @"type" : @"Point"};
    [_rideParametersDictionary setObject:pickupLocDict forKey:@"pickupLocation"];
    
    if([self validateRideRequestParameters]){
        [self showLoadingView:YES];
        [self performSelectorInBackground:@selector(requestRideInBackground) withObject:nil];
    }else{
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC-incompleteRideParams_title", @"") andMessage:NSLocalizedString(@"MFC-incompleteRideParams_message", @"")] animated:YES completion:nil];
    }
}
//Segue goConfirmRideSeguw

-(void)requestRideInBackground{
    
    NSLog(@"will request ride : %@", _rideParametersDictionary);
    @autoreleasepool {
        NSDictionary *params = @{
                                 @"ride" : _rideParametersDictionary
                                 };
        [RidesServiceManager requestNewRide:params :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishRequestRide:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishRequestRide:(NSDictionary *)response{
    NSLog(@"ride request response : %@", response);
    [self showLoadingView:NO];
    if(response && ([response objectForKey:@"data"]) && ([[response objectForKey:@"code"] intValue] == 200)){
        //Save client info from response
        if([response objectForKey:@"client"]){
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"client"] andAccessToken:nil];
        }
        _rideParametersDictionary = [[response objectForKey:@"data"] mutableCopy];
        [self performSegueWithIdentifier:@"goOnRideSegue" sender:self];
    }else{
        [self createRideServerValidation:response];
    }
}

#pragma mark - Loading View
-(void)showLoadingView:(BOOL)show{
    if(show) {
        loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.7;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.center = loadingView.center;
        indicator.color = [UIColor whiteColor];
        [indicator startAnimating];
        [loadingView addSubview:indicator];
        
        [self.view addSubview:loadingView];
        [self.view bringSubviewToFront:loadingView];
    }else{
        [loadingView removeFromSuperview];
    }
}

#pragma mark - Finally, Validate ride request parameters
-(BOOL)validateRideRequestParameters{
    if(![_rideParametersDictionary objectForKey:@"category"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_cat_title", @"") andMessage:NSLocalizedString(@"MFC_missing_cat_message", @"")] animated:YES completion:nil];
        return NO;
    }
    if(![_rideParametersDictionary objectForKey:@"currentLocation"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_currentLoc_title", @"") andMessage:NSLocalizedString(@"MFC_missing_currentLoc_message", @"")] animated:YES completion:nil];
        return NO;
    }

    if(![_rideParametersDictionary objectForKey:@"pickupLocation"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_pickupLocation_title", @"") andMessage:NSLocalizedString(@"MFC_missing_pickupLocation_message", @"")] animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Error from server? let's validate
-(void)createRideServerValidation:(NSDictionary *)response{
    if([[response objectForKey:@"code"] intValue] == 400){
        if([[[response objectForKey:@"errors"] objectForKey:@"accessToken"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"error_title", @"") andMessage:NSLocalizedString(@"error_message", @"")] animated:YES completion:nil];
        }
        if([[[response objectForKey:@"errors"] objectForKey:@"category"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_cat_title", @"") andMessage:NSLocalizedString(@"MFC_missing_cat_message", @"")] animated:YES completion:nil];
        }
        if([[[response objectForKey:@"errors"] objectForKey:@"currentLocation"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_currentLoc_title", @"") andMessage:NSLocalizedString(@"MFC_missing_currentLoc_message", @"")] animated:YES completion:nil];
        }
        if([[[response objectForKey:@"errors"] objectForKey:@"dropoffLocation"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_dropoffLocation_title", @"") andMessage:NSLocalizedString(@"MFC_missing_dropoffLocation_message", @"")] animated:YES completion:nil];
        }
        if([[[response objectForKey:@"errors"] objectForKey:@"pickupLocation"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_pickupLocation_title", @"") andMessage:NSLocalizedString(@"MFC_missing_pickupLocation_message", @"")] animated:YES completion:nil];
        }
    }else if([[response objectForKey:@"code"] intValue] == 404){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"PCC_no_drivers_title", @"") andMessage:NSLocalizedString(@"PCC_no_drivers_message", @"")] animated:YES completion:nil];
    }else{
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"error_title", @"") andMessage:NSLocalizedString(@"error_message", @"")] animated:YES completion:nil];
    }
}




- (IBAction)choosePickupLocationBtnAction:(UIButton *)sender {
    chooseLocationView = [[PickupLocationView alloc] initWithFrame:self.view.frame];
    chooseLocationView.delegate = self;
    [self.view addSubview:chooseLocationView];
}

#pragma mark - Location View Delegate Methods
-(void)dismissView{
    [chooseLocationView removeFromSuperview];
    chooseLocationView = nil;
}

-(void)setChosenLocation:(NSDictionary *)choosedLocation{
    _PickupLocationLabel.text = [choosedLocation objectForKey:@"titleString"];
    
    [_rideParametersDictionary setObject:choosedLocation forKey:@"dropoffLocation"];
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:CLLocationCoordinate2DMake([[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:0] doubleValue], [[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:1] doubleValue]) zoom:15];
    [_mapView animateWithCameraUpdate:updatedCamera];
    
}

- (IBAction)backBtnAction:(UIButton *)sender {
    if(self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)luggageBtnAction:(UIButton *)sender {
    luggage = !luggage;
    if(luggage){
        [_rideParametersDictionary setObject:[NSNumber numberWithInt:1] forKey:@"isLuggage"];
        [_luggageView setBackgroundColor:selectedBGColor];
        [_luggageIcon setTintColor:selectedIconTintColor];
        [_luggageLabel setTextColor:selectedIconTintColor];
    }else{
        [_rideParametersDictionary setObject:[NSNumber numberWithInt:0] forKey:@"isLuggage"];
        [_luggageView setBackgroundColor:notSelectedBGColor];
        [_luggageIcon setTintColor:notSelectedIconTintColor];
        [_luggageLabel setTextColor:notSelectedIconTintColor];
    }
}
- (IBAction)quietRideBtnAction:(UIButton *)sender {
    quietRide = !quietRide;
    if(quietRide){
        [_rideParametersDictionary setObject:[NSNumber numberWithInt:1] forKey:@"isQuiet"];
        [_quietView setBackgroundColor:selectedBGColor];
        [_quietIcon setTintColor:selectedIconTintColor];
        [_quietLabel setTextColor:selectedIconTintColor];
    }else{
        [_rideParametersDictionary setObject:[NSNumber numberWithInt:0] forKey:@"isQuiet"];
        [_quietView setBackgroundColor:notSelectedBGColor];
        [_quietIcon setTintColor:notSelectedIconTintColor];
        [_quietLabel setTextColor:notSelectedIconTintColor];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goOnRideSegue"]) {
        NSLog(@"will go with params : %@", _rideParametersDictionary);
    }
}
@end

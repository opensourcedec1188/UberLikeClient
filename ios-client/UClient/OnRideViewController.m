//
//  OnRideViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 9/9/1438 AH.
//  Copyright © 1438 Ego. All rights reserved.
//

#import "OnRideViewController.h"
#import "AppDelegate.h"

@interface OnRideViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@end

@implementation OnRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _applicationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Add observer for background/Foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self prepareOnRidePrerequests];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Set map view on current location
    GMSCameraPosition *mapCamera = [GMSCameraPosition cameraWithLatitude:self.applicationDelegate.currentLocation.coordinate.latitude
                                          longitude:self.applicationDelegate.currentLocation.coordinate.longitude
                                               zoom:14];
    _mapView.myLocationEnabled = NO;
    _mapView.settings.consumesGesturesInView = NO;
    _mapView.delegate = self;
    [_mapView setCamera:mapCamera];
    
    //Map Style
    GMSMapStyle *style = [RidesServiceManager setMapStyleFromFileName:@"style"];
    if(style)
        [_mapView setMapStyle:style];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_headerView edgeInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) andShadowRadius:25.0f];
    _headerView.layer.shadowPath = shadowPath.CGPath;
       
    //Get Cancellation Reasons
    [self performSelectorInBackground:@selector(getCancelationReasonsInBG) withObject:nil];
    
    UIView *above = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    CAGradientLayer *gradientAbove = [CAGradientLayer layer];
    
    gradientAbove.frame = above.bounds;
    gradientAbove.colors = @[(id)[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0].CGColor, (id)[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.0].CGColor];
    gradientAbove.startPoint = CGPointMake(0.0, 0.0);
    gradientAbove.endPoint = CGPointMake(0.0, 1.0);
    
    [above.layer insertSublayer:gradientAbove atIndex:0];
    [self.view insertSubview:above aboveSubview:_mapView];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)getCancelationReasonsInBG{
    @autoreleasepool {
        [RidesServiceManager getCancelationReasons:^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetCancelationReasonsInBG:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetCancelationReasonsInBG:(NSDictionary *)response{
    NSLog(@"finishGetCancelationReasonsInBG : %@", response);
    if(response && [response objectForKey:@"data"]){
        cancelationReasons = [response objectForKey:@"data"];
    }
}

#pragma mark - Background/Foreground Observers
/*
 If app is coming from background, Should
 - Invoke getCurrentRide method
 - It will return: Ride/Client/Driver/Vehicle
 */
- (void)enterForeground {
    [self prepareOnRidePrerequests];
}

#pragma mark - Initiate Pusher Client
-(void)initiateRideStatusPubnubManager{
    if(!_pubnubManager){
        _pubnubManager = [[PupnubRideManager alloc] initManager];
        [_pubnubManager listenToChannelName:[NSString stringWithFormat:@"ride-tracking-%@", [_rideData objectForKey:@"_id"]]];
        [_pubnubManager listenToChannelName:[NSString stringWithFormat:@"clients-%@", [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"]]];
        _pubnubManager.listnerDelegate = self;
    }
}

- (IBAction)myLocationButton:(UIButton *)sender {
    [_mapView animateToLocation:_applicationDelegate.currentLocation.coordinate];
}

#pragma mark - Ride-Prerequests

-(void)prepareOnRidePrerequests{
    [self performSelectorInBackground:@selector(getCurrentRideInBG) withObject:nil];
}
-(void)getCurrentRideInBG{
    @autoreleasepool {
        [RidesServiceManager getRide:[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"lastRideId"] :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetCurrentRide:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetCurrentRide:(NSDictionary *)response{
    NSLog(@"finishGetCurrentRide : %@", response);
    if(response && ([response objectForKey:@"data"])){
        
        _rideData = [RidesServiceManager prepareRideDictionary:[response objectForKey:@"data"]];
        
        if([response objectForKey:@"client"])
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"client"] andAccessToken:nil];
        
        if([response objectForKey:@"driver"])
            _driverData = [response objectForKey:@"driver"];
        
        if([response objectForKey:@"vehicle"])
            _vehicleData = [response objectForKey:@"vehicle"];
        //Call the method that adjust view with current ride status
        [self finishOnRidePrerequests];
        
    }else{
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"error_title", @"") andMessage:NSLocalizedString(@"error_message", @"")] animated:YES completion:nil];
    }
}

-(void)finishOnRidePrerequests{
    if([[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"isOnRide"] intValue] == 1){
        //On-Ride, get currentRide from response,
        //If response has no currentRide, Get it from server
        [self refreshView];
    }else{
        //Not on-ride, if
        //Not rated -- lastRideRatingStatus
        //Canceled by driver/System/TechSupport -- Handle cancelation
        //else, Go gome
        NSString *lastRideMessage = [[ServiceManager getClientDataFromUserDefaults] objectForKey:@"lastRideMessage"];
        if([lastRideMessage isEqualToString:@"not-rated"]){
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else if(([lastRideMessage isEqualToString:@"canceled-by-driver"])){
            
            [self handleCancelRideBySystemOrDriver:1];
            
        }else if(([lastRideMessage isEqualToString:@"canceled-by-system"]) || ([lastRideMessage isEqualToString:@"canceled-by-tech-support"])){
            
            [self handleCancelRideBySystemOrDriver:2];
            
        }else{
            
        }
    }
}

#pragma mark - Refresh ride info on screen
-(void)refreshView{
    [self initiateRideStatusPubnubManager];
    //Check if this client already on-ride
    NSString *status = [_rideData objectForKey:@"status"];
    
    if([[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"isOnRide"] intValue] == 1){
        
        if(!driverMarker || (driverMarker.map == nil)){
            if([HelperClass checkCoordinates:[_rideData objectForKey:@"lastDriverLocation"]]){
                CLLocationCoordinate2D newMarkerCenter = CLLocationCoordinate2DMake([[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
                [self drawNewDriverMarkerWithlocationCoordinates:newMarkerCenter];
            }
        }
        
        if([status isEqualToString:@"initiated"]){
            [self showInitialFooterView:YES instantHide:YES];
            if([HelperClass checkCoordinates:[_rideData objectForKey:@"pickupLocation"]])
                [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake([[[[_rideData objectForKey:@"pickupLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[[_rideData objectForKey:@"pickupLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]) zoom:16]];
            [_mapView animateToViewingAngle:90];
            
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_initiated", @"");
        }else if ([status isEqualToString:@"accepted"]){
            [self showAcceptedCancelView:YES instantHide:YES];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_accepted", @"");
            [_mapView animateToViewingAngle:0];
            
        }else if(([status isEqualToString:@"nearby"])){
            [self showAcceptedCancelView:YES instantHide:YES];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_driver_nearby", @"");
            [_mapView animateToViewingAngle:0];
            
        }else if(([status isEqualToString:@"arrived"])){
            [self showAcceptedCancelView:YES instantHide:YES];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_arrived", @"");
            [_mapView animateToViewingAngle:0];
            
            mainMapPolyline.map = nil;
            mainMapPolyline = nil;
            
        }else if([status isEqualToString:@"on-ride"]){
            [self showOnRideFooterView:YES instantHide:YES];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_on_ride", @"");
            [_mapView animateToViewingAngle:0];
            
        }else if([status isEqualToString:@"clearance"]){
            [self showOnRideFooterView:YES instantHide:YES];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_clearance", @"");
            [_mapView animateToViewingAngle:90];
            
            mainMapPolyline.map = nil;
            mainMapPolyline = nil;
            
        }else if([status isEqualToString:@"finished"]){
            [self showOnRideFooterView:YES instantHide:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if([status isEqualToString:@"ride-canceled"]){
            
            [self handleCancelRideBySystemOrDriver:1];
            
        }else if([status isEqualToString:@"ride-auto-canceled"]){
            
            [self handleCancelRideBySystemOrDriver:2];
            
        }
    }else{
        [self presentViewController:[HelperClass showAlert:@"Wrong Place" andMessage:@"You should not be here, Please contact us"] animated:YES completion:nil];
    }
//    [self MoveDriverMarkerAndResultRoute];
    [self prepareCurrentRouteAndMarkers];
    //Destination Label
    [self setHeaderDropOffLabel];
}

#pragma mark - Show Cancel While Initiated View (Before Acceptance)
-(void)showInitialFooterView:(BOOL)show instantHide:(BOOL)insantHide{
    
    CGRect initialFrame = self.view.bounds;
    if(show){
        [self showAcceptedCancelView:NO instantHide:YES];
        [self showOnRideFooterView:NO instantHide:YES];
        if(!initiatedFooterView){
            [initiatedFooterView removeFromSuperview];
            initiatedFooterView = nil;
            initiatedFooterView = [[InitiatedRideFooterView alloc] initWithFrame:initialFrame];
            initiatedFooterView.delegate = self;
            [initiatedFooterView setHidden:YES];
            initiatedFooterView.clipsToBounds = NO;
            [self.view addSubview:initiatedFooterView];
            
            initiatedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [initiatedFooterView setHidden:NO];
                                 initiatedFooterView.frame = initialFrame;
                             }completion:^(BOOL finished){
                                 [initiatedFooterView showCustomLoadingView:YES];
                             }];
        }else{
            initiatedFooterView.progressView.indeterminate = YES;
            initiatedFooterView.progressView.animateStripes = YES;
            initiatedFooterView.progressView.showStripes = YES;
        }
    }else{
        if(!insantHide){
            initiatedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 initiatedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
                             }completion:^(BOOL finished){
                                 [initiatedFooterView removeFromSuperview];
                                 initiatedFooterView = nil;
                             }];
        }else{
            [initiatedFooterView removeFromSuperview];
            initiatedFooterView = nil;
        }
    }
}


#pragma mark - Accepted Footer View
-(void)showAcceptedCancelView:(BOOL)show instantHide:(BOOL)insantHide{
    CGRect initialFrame = CGRectMake(0, _acceptedCancelView.frame.origin.y, self.view.frame.size.width, _acceptedCancelView.frame.size.height+65);
    [acceptedFooterView.initialCancelConfirmBGView removeFromSuperview];
    if(show){
        [self showInitialFooterView:NO instantHide:YES];
        [self showOnRideFooterView:NO instantHide:YES];
        if(!acceptedFooterView){
            [acceptedFooterView removeFromSuperview];
            acceptedFooterView = nil;
            acceptedFooterView = [[AcceptedRideFooterView alloc] initWithFrame:initialFrame];
            acceptedFooterView.delegate = self;
            [acceptedFooterView setHidden:YES];
            acceptedFooterView.clipsToBounds = NO;
            [self.view addSubview:acceptedFooterView];
            
            if(_driverData && !([_driverData isKindOfClass:[NSNull class]]) && ([_driverData objectForKey:@"firstName"]) && ([_driverData objectForKey:@"lastName"])){
                NSString *fName = [_driverData objectForKey:@"firstName"];
                acceptedFooterView.acceptedDriverNameLabel.text = [NSString stringWithFormat:@"%@", fName];
                acceptedFooterView.accceptedDriverRateLabel.text = [NSString stringWithFormat:@"%.2f", [[_driverData objectForKey:@"ratingsAvg"] floatValue]];
                
                NSString *driverPhotoURL = [_driverData objectForKey:@"photoUrl"];
                [acceptedFooterView.acceptedDriverImageView setImageWithURL:[NSURL URLWithString:driverPhotoURL] placeholderImage:[UIImage imageNamed:@"person"]];
                acceptedFooterView.acceptedDriverImageView.layer.cornerRadius = acceptedFooterView.acceptedDriverImageView.frame.size.height/2;
                acceptedFooterView.acceptedDriverImageView.layer.masksToBounds = YES;
                
                UIBezierPath *acceptedDriverImageViewShadowPath = [UIHelperClass setViewShadow:acceptedFooterView.acceptedDriverImageView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:25.0f];
                acceptedFooterView.acceptedDriverImageView.layer.shadowPath = acceptedDriverImageViewShadowPath.CGPath;
            }
            
            if(_vehicleData && !([_vehicleData isKindOfClass:[NSNull class]])){
                
                NSString *manufacturer = [_vehicleData objectForKey:@"manufacturer"];
                NSString *model = [_vehicleData objectForKey:@"model"];
                acceptedFooterView.acceptedVehicleLabel.text = [NSString stringWithFormat:@"%@ %@", manufacturer, model];
                
                acceptedFooterView.acceptedVehicleNumLabel.text = [NSString stringWithFormat:@"%i - %@", [[_vehicleData objectForKey:@"plateNumber"] intValue], [_vehicleData objectForKey:@"plateLetters"]];
                
                [acceptedFooterView.acceptedVehicleImageView setImageWithURL:[NSURL URLWithString:[_vehicleData objectForKey:@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"Processing_Page_Vehicle_Image.png"]];
                acceptedFooterView.acceptedVehicleImageView.layer.cornerRadius = acceptedFooterView.acceptedVehicleImageView.frame.size.height/2;
                acceptedFooterView.acceptedVehicleImageView.layer.masksToBounds = YES;
            }
            acceptedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [acceptedFooterView setHidden:NO];
                                 acceptedFooterView.frame = initialFrame;
                             }completion:^(BOOL finished){}];
        }
    }else{
        if(!insantHide){
            acceptedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 acceptedFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
                             }completion:^(BOOL finished){
                                 
                                 [acceptedFooterView removeFromSuperview];
                                 acceptedFooterView = nil;
                             }];
        }else{
            [acceptedFooterView removeFromSuperview];
            acceptedFooterView = nil;
        }
    }
    
}

#pragma mark - Accepted Footer Delegate
-(void)cancelAction{
    [self performSelectorInBackground:@selector(cancelRideInBackground:) withObject:@{@"rideID" : [_rideData objectForKey:@"_id"]}];
}

#pragma mark - Show Cancel While Initiated View (Before Acceptance)
-(void)showOnRideFooterView:(BOOL)show instantHide:(BOOL)insantHide{
    CGRect initialFrame = CGRectMake(0, _onRideCancelView.frame.origin.y, self.view.frame.size.width, 496);
    [onRideFooterView.onRideCancelConfirmBGView removeFromSuperview];
    if(show){
        [self showInitialFooterView:NO instantHide:YES];
        [self showAcceptedCancelView:NO instantHide:YES];
        if(!onRideFooterView){
            [onRideFooterView removeFromSuperview];
            onRideFooterView = nil;
            onRideFooterView = [[OnRideFooterView alloc] initWithFrame:initialFrame andArray:cancelationReasons];
            onRideFooterView.delegate = self;
            [onRideFooterView setHidden:YES];
            onRideFooterView.clipsToBounds = NO;
            [self.view addSubview:onRideFooterView];
            
            if([[_rideData objectForKey:@"status"] isEqualToString:@"clearance"]){
                if([_rideData objectForKey:@"canceledBy"]){
                    if([[_rideData objectForKey:@"canceledBy"] isEqualToString:@"client"]){
                        [onRideFooterView.canceledRideView setHidden:NO];
                    }
                }
            }
            
            if(_driverData && !([_driverData isKindOfClass:[NSNull class]]) && ([_driverData objectForKey:@"firstName"]) && ([_driverData objectForKey:@"lastName"])){
                NSString *fName = [_driverData objectForKey:@"firstName"];
                onRideFooterView.driverNameLabel.text = [NSString stringWithFormat:@"%@", fName];
                onRideFooterView.driverRateLabel.text = [NSString stringWithFormat:@"%.2f", [[_driverData objectForKey:@"ratingsAvg"] floatValue]];
                NSString *driverPhotoURL = [_driverData objectForKey:@"photoUrl"];
                [onRideFooterView.driverImageView setImageWithURL:[NSURL URLWithString:driverPhotoURL] placeholderImage:[UIImage imageNamed:@"person"]];
                onRideFooterView.driverImageView.layer.cornerRadius = onRideFooterView.driverImageView.frame.size.height/2;
                onRideFooterView.driverImageView.layer.masksToBounds = YES;
                
                UIBezierPath *acceptedDriverImageViewShadowPath = [UIHelperClass setViewShadow:onRideFooterView.driverImageView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:25.0f];
                onRideFooterView.driverImageView.layer.shadowPath = acceptedDriverImageViewShadowPath.CGPath;
            }
            
            if(_vehicleData && !([_vehicleData isKindOfClass:[NSNull class]])){
                
                [onRideFooterView.vehicleImageView setImageWithURL:[NSURL URLWithString:[_vehicleData objectForKey:@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"Processing_Page_Vehicle_Image.png"]];
                onRideFooterView.vehicleImageView.layer.cornerRadius = onRideFooterView.vehicleImageView.frame.size.height/2;
                onRideFooterView.vehicleImageView.layer.masksToBounds = YES;
                
            }
            
            onRideFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [onRideFooterView setHidden:NO];
                                 onRideFooterView.frame = initialFrame;
                             }completion:^(BOOL finished){}];
        }
    }else{
        if(!insantHide){
            onRideFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 onRideFooterView.frame = CGRectMake(initialFrame.origin.x, self.view.frame.size.height, initialFrame.size.width, initialFrame.size.height);
                             }completion:^(BOOL finished){
                                 [onRideFooterView removeFromSuperview];
                                 onRideFooterView = nil;
                             }];
        }else{
            [onRideFooterView removeFromSuperview];
            onRideFooterView = nil;
        }
    }
}

#pragma mark - OnRide Footer Delegate
-(void)cancelActionWithReason:(NSString *)reasonString{
    [self performSelectorInBackground:@selector(cancelRideInBackground:) withObject:@{@"rideID" : [_rideData objectForKey:@"_id"], @"cancellationReason" : reasonString}];
}




#pragma mark - Call Driver Delegate
-(void)callDriverPhone{
    if(_driverData){
        NSString *phNo = [_driverData objectForKey:@"phone"];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
        
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {}];
    }
}

#pragma mark - Header Labels
-(void)setHeaderDropOffLabel{
    NSString *enAddress = [_rideData objectForKey:@"englishDropoffAddress"];
    if((enAddress) && (enAddress.length > 0)){
        _headerDestinationLabel.text = enAddress;
    }else if([HelperClass checkCoordinates:[_rideData objectForKey:@"dropoffLocation"]]){
        [GoogleServicesManager getAddressFromCoordinates:[[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue]
         andLong:[[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]
         :^(NSDictionary *response){
            _headerDestinationLabel.text = [NSString stringWithFormat:@"To: %@", [response objectForKey:@"address"]];
        }];
    }else
        _headerDestinationLabel.text = NSLocalizedString(@"MFC_skipped", @"");
}

#pragma Mark - Method that call car animation and re-route
-(void)prepareCurrentRouteAndMarkers{
    CLLocation *firstLocation = nil;
    CLLocation *lastLocation = nil;
    NSString *rideStatus = [_rideData objectForKey:@"status"];
    if(([rideStatus isEqualToString:RIDE_STATUS_ACCEPTED]) || ([rideStatus isEqualToString:RIDE_STATUS_NEARBY])){
        [self drawPickupMarker];
        
        lastLocation = [[CLLocation alloc] initWithLatitude:[[[[_rideData objectForKey:@"pickupLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue] longitude:[[[[_rideData objectForKey:@"pickupLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]];
        
        if(currentComingDriverLocation){
            firstLocation = [[CLLocation alloc] initWithLatitude:currentComingDriverLocation.coordinate.latitude longitude:currentComingDriverLocation.coordinate.longitude];
        }else{
            if([HelperClass checkCoordinates:[_rideData objectForKey:@"lastDriverLocation"]]){
                firstLocation = [[CLLocation alloc] initWithLatitude:[[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue] longitude:[[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]];
            }
        }
        if(firstLocation && lastLocation){
            double distance = [HelperClass distanceBetweenFirst:firstLocation andSecond:lastLocation];
            if(distance < 300)
                [self drawGoRouteFromSource:firstLocation toDestination:lastLocation];
        }
        
    }else if(([rideStatus isEqualToString:RIDE_STATUS_STARTED]) || ([rideStatus isEqualToString:RIDE_STATUS_ENDED]) || ([rideStatus isEqualToString:RIDE_STATUS_FINISHED])){
        
        if([HelperClass checkCoordinates:[_rideData objectForKey:@"dropoffLocation"]]){
            [self drawDropOffMarker];
            
            lastLocation = [[CLLocation alloc] initWithLatitude:[[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue] longitude:[[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]];
            
            if(currentComingDriverLocation){
                firstLocation = [[CLLocation alloc] initWithLatitude:currentComingDriverLocation.coordinate.latitude longitude:currentComingDriverLocation.coordinate.longitude];
            }else{
                if([HelperClass checkCoordinates:[_rideData objectForKey:@"lastDriverLocation"]]){
                    firstLocation = [[CLLocation alloc] initWithLatitude:[[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue] longitude:[[[[_rideData objectForKey:@"lastDriverLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]];
                }
            }
        }
    }
    if(firstLocation && lastLocation){
        double distance = [HelperClass distanceBetweenFirst:firstLocation andSecond:lastLocation];
        if(distance > 300)
            [self drawGoRouteFromSource:firstLocation toDestination:lastLocation];
    }
}

-(void)drawGoRouteFromSource:(CLLocation *)sourceLocation toDestination:(CLLocation *)destLocation{
    //Call GoogleMaps API to get route to pickup location
    if(sourceLocation && destLocation)
        [self performSelectorInBackground:@selector(getGoogleAPIPath:) withObject:@{@"source" : sourceLocation, @"dest" : destLocation}];
}

-(void)getGoogleAPIPath:(NSDictionary *)location{
    @autoreleasepool {
        CLLocation *source = (CLLocation *)[location objectForKey:@"source"];
        CLLocation *dest = (CLLocation *)[location objectForKey:@"dest"];
        [GoogleServicesManager getRouteFrom:source.coordinate to:dest.coordinate :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishGetRoute:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishGetRoute:(NSDictionary *)response{
    if([response objectForKey:@"status"]){
        if([[response objectForKey:@"status"] isEqualToString:@"OK"]){
            
            if([[response objectForKey:@"routes"] isKindOfClass:[NSArray class]]){
                if([[response objectForKey:@"routes"] objectAtIndex:0]){
                    if([[[response objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"]){
                        NSDictionary *pathsV = [[[response objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"];
                        
                        mainMapPolyline.map = nil;
                        mainMapPolyline = nil;
                        mainMapPath = nil;
                        
                        mainMapPath = [GMSMutablePath pathFromEncodedPath:[pathsV objectForKey:@"points"]];
                        mainMapPolyline = [GMSPolyline polylineWithPath:mainMapPath];
                        mainMapPolyline.strokeWidth = 5;
                        mainMapPolyline.strokeColor = [UIColor grayColor];
                        GMSStrokeStyle *redBlue = [GMSStrokeStyle gradientFromColor:[UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f] toColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0f]];
                        mainMapPolyline.spans = @[[GMSStyleSpan spanWithStyle:redBlue]];
                        mainMapPolyline.map = _mapView;
                    }
                }
            }
        }
    }
}

#pragma mark - Pickup Marker
-(void)drawPickupMarker{
    if(!pickupMarker){
        NSArray *locationArray;
        if([HelperClass checkCoordinates:[_rideData objectForKey:@"onRideDriverLocation"]])
            locationArray = [[_rideData objectForKey:@"onRideDriverLocation"] objectForKey:@"coordinates"];
        else{
            if([HelperClass checkCoordinates:[_rideData objectForKey:@"pickupLocation"]])
                locationArray = [[_rideData objectForKey:@"pickupLocation"] objectForKey:@"coordinates"];
        }
        if([locationArray count] > 0){
            CLLocationCoordinate2D pickupLoc = CLLocationCoordinate2DMake([[locationArray objectAtIndex:0] floatValue], [[locationArray objectAtIndex:1] floatValue]);
            if((!pickupMarker) && !pickupMarker.map)
                pickupMarker = [[GMSMarker alloc] init];
            pickupMarker.position = pickupLoc;
            pickupMarker.icon = [UIImage imageNamed:@"PinImage"];
            pickupMarker.map = _mapView;
        }
    }
}

#pragma mark - Drop-Off Marker
-(void)drawDropOffMarker{
    if([HelperClass checkCoordinates:[_rideData objectForKey:@"dropoffLocation"]]){
        CLLocationCoordinate2D dropOffLoc = CLLocationCoordinate2DMake([[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[[_rideData objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
        dropOffMarker.map = nil;
        dropOffMarker = nil;
        
        dropOffMarker = [[GMSMarker alloc] init];
        dropOffMarker.position = dropOffLoc;
        dropOffMarker.title = @"Drop Off";
        dropOffMarker.snippet = @"Drop Off";
        dropOffMarker.icon = [UIImage imageNamed:@"PinImage"];
        dropOffMarker.map = _mapView;
    }
}

#pragma mark - Show Local Notification
-(void)showLoaclNotificationWithTitle:(NSString *)title andBody:(NSString *)body{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        
        content.sound = [UNNotificationSound defaultSound];
        content.badge = @-1;
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        content.title = title;
        content.body = body;
        // Create the request object.
        UNNotificationRequest* request = [UNNotificationRequest
                                          requestWithIdentifier:@"ridesLocalNotification" content:content trigger:trigger];
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        
        //Local Notification
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"errr %@", error.localizedDescription);
            }else{
                NSLog(@"should send");
            }
        }];
    }
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    if([notification.request.identifier isEqualToString:@"ridesLocalNotification"])
        completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound);
}

#pragma mark - Handle Ride Cancellation
/* Params: cancelSource: canceled by driver, TechSupport, System, .. etc. */
-(void)handleCancelRideBySystemOrDriver:(int)cancelSource{
    [self performSelectorInBackground:@selector(dismissLastRideMessageInBG) withObject:nil];
    if(_rideData){
        NSString *title = @"";
        NSString *message = @"";
        switch (cancelSource) {
            case 1://driver
                title = NSLocalizedString(@"PCC_cancel_warning_driver_title", @"");
                message = NSLocalizedString(@"PCC_cancel_warning_driver_message", @"");
                break;
            case 2://system
                title = NSLocalizedString(@"PCC_cancel_warning_auto_title", @"");
                message = NSLocalizedString(@"PCC_cancel_warning_driver_message", @"");
                break;
                
            default:
                break;
        }
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesBtn = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"yes", @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self requestNewRide:YES];
                                 }];
        UIAlertAction *noBtn = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"no", @"")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }];
        [alert addAction:noBtn];
        [alert addAction:yesBtn];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - Finished, Request Ride
#pragma mark - Request new ride
-(void)requestNewRide:(BOOL)addCurrentLocation{
    if(addCurrentLocation){
        NSMutableDictionary *newRideDictionary = [[NSMutableDictionary alloc] init];
        
        [newRideDictionary setObject:@{@"coordinates" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.longitude], nil], @"type" : @"Point"} forKey:@"currentLocation"];
        if([HelperClass checkCoordinates:[_rideData objectForKey:@"pickupLocation"]])
            [newRideDictionary setObject:[_rideData objectForKey:@"pickupLocation"] forKey:@"pickupLocation"];
        
        if([HelperClass checkCoordinates:[_rideData objectForKey:@"dropoffLocation"]])
            [newRideDictionary setObject:[_rideData objectForKey:@"dropoffLocation"] forKey:@"dropoffLocation"];
        
        if([_rideData objectForKey:@"isLuggage"])
            [newRideDictionary setObject:[_rideData objectForKey:@"isLuggage"] forKey:@"isLuggage"];
        
        if([_rideData objectForKey:@"isQuiet"])
            [newRideDictionary setObject:[_rideData objectForKey:@"isQuiet"] forKey:@"isQuiet"];
        
        if([_rideData objectForKey:@"comment"])
            [newRideDictionary setObject:[_rideData objectForKey:@"comment"] forKey:@"comment"];
        
        if([_rideData objectForKey:@"category"])
            [newRideDictionary setObject:[_rideData objectForKey:@"category"] forKey:@"category"];
        
        NSLog(@"requestNewRide -- ride parameters : %@ From Ride %@", newRideDictionary, _rideData);
        
        if([self validateRideRequestParameters]){
            [self showLoadingView:YES];
            [self performSelectorInBackground:@selector(requestRideInBackground:) withObject:newRideDictionary];
        }else{
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC-incompleteRideParams_title", @"") andMessage:NSLocalizedString(@"MFC-incompleteRideParams_message", @"")] animated:YES completion:nil];
        }
    }
}
//Segue goConfirmRideSeguw

-(void)requestRideInBackground:(NSDictionary *)parameters{
    
    @autoreleasepool {
        NSDictionary *params = @{
                                 @"ride" : parameters
                                 };
        [RidesServiceManager requestNewRide:params :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishRequestRide:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishRequestRide:(NSDictionary *)response{
    [self showLoadingView:NO];
    if(response && ([response objectForKey:@"data"]) && ([[response objectForKey:@"code"] intValue] == 200)){
        //Save client info from response
        if([response objectForKey:@"client"]){
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"client"] andAccessToken:nil];
        }
        _rideData = [response objectForKey:@"data"];
        [self refreshView];
    }else{
        [self createRideServerValidation:response];
    }
}

-(void)dismissLastRideMessageInBG{
    @autoreleasepool {
        [RidesServiceManager dismissLastRideCancelation:^(NSDictionary *completion){
            [self performSelectorOnMainThread:@selector(finishDismissLastRideMessageInBG:) withObject:completion waitUntilDone:NO];
        }];
    }
}

-(void)finishDismissLastRideMessageInBG:(NSDictionary *)response{
    if([response objectForKey:@"data"])
        [ServiceManager saveLoggedInClientData:[response objectForKey:@"data"] andAccessToken:nil];
}

#pragma mark - Pubnub receive messages delegate (Coming Driver Tracking)
-(void)receivedMessageFromDriverOnPupnub:(NSDictionary *)message {
    NSLog(@"received message from pubnub %@", message);
    //Message for tracking
    if([message objectForKey:@"locationInfo"]){
        id lastLocation = [[[message objectForKey:@"locationInfo"] objectForKey:@"locations"] lastObject];
        if(([lastLocation objectForKey:@"latitude"]) && ([lastLocation objectForKey:@"longitude"])){
            CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake([[lastLocation objectForKey:@"latitude"] doubleValue], [[lastLocation objectForKey:@"longitude"] doubleValue]);
            if(mainMapPath != nil){
                if(!GMSGeometryIsLocationOnPathTolerance(lastCoordinate, mainMapPath, NO, 80)){
                    [self prepareCurrentRouteAndMarkers];
                }
            }
            
        }

        currentComingDriverLocation = [[CLLocation alloc] initWithLatitude:[[lastLocation objectForKey:@"latitude"] floatValue] longitude:[[lastLocation objectForKey:@"longitude"] floatValue]];
        if(([driverMarker isKindOfClass:[GMSMarker class]]) && driverMarker && !(driverMarker.map == nil)){

            if(!driverMarker.map)
                driverMarker.map = _mapView;
            if([[message objectForKey:@"locationInfo"] isKindOfClass:[NSDictionary class]]){
                if([[message objectForKey:@"locationInfo"] objectForKey:@"locations"]){
                    NSArray *locationsArray = [[message objectForKey:@"locationInfo"] objectForKey:@"locations"];
                    [self handleAnimationArray:locationsArray];
                }
            }
        }else{
            if(([lastLocation objectForKey:@"latitude"]) && ([lastLocation objectForKey:@"longitude"])){
                CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake([[lastLocation objectForKey:@"latitude"] doubleValue], [[lastLocation objectForKey:@"longitude"] doubleValue]);
                [self drawNewDriverMarkerWithlocationCoordinates:lastCoordinate];
            }
        }
        
    }else if([message objectForKey:@"event"]){
        //Message for Ride-Status
        NSString *event = [message objectForKey:@"event"];
        if([event isEqualToString:@"ride-accepted"]){
            [self prepareOnRidePrerequests];
            [self showLoaclNotificationWithTitle:NSLocalizedString(@"PCC_headet_title_accepted", @"") andBody:NSLocalizedString(@"PCC_headet_body_accepted", @"")];
            
        }else if([event isEqualToString:@"driver-nearby"]){
            [self prepareOnRidePrerequests];
            [self showLoaclNotificationWithTitle:NSLocalizedString(@"PCC_headet_title_driver_nearby", @"") andBody:NSLocalizedString(@"PCC_headet_body_driver_nearby", @"")];
            
        }else if([event isEqualToString:@"driver-arrived"]){
            driverMarker.title = @"";
            driverMarker.snippet = @"";
            [self prepareOnRidePrerequests];
            [self showLoaclNotificationWithTitle:NSLocalizedString(@"PCC_headet_title_arrived", @"") andBody:NSLocalizedString(@"PCC_headet_body_arrived", @"")];
            
            mainMapPolyline.map = nil;
            mainMapPolyline = nil;
            
        }else if([event isEqualToString:@"ride-begun"]){
            [self showLoaclNotificationWithTitle:NSLocalizedString(@"PCC_headet_title_on_ride", @"") andBody:NSLocalizedString(@"PCC_headet_body_on_ride", @"")];
            [self prepareOnRidePrerequests];
            
        }else if([event isEqualToString:@"ride-cleared"]){
            [self prepareOnRidePrerequests];
            [self showLoaclNotificationWithTitle:NSLocalizedString(@"PCC_headet_title_clearance", @"") andBody:NSLocalizedString(@"PCC_headet_body_clearance", @"")];
            
            mainMapPolyline.map = nil;
            mainMapPolyline = nil;
            
        }else if([event isEqualToString:@"ride-finished"]){
            [self prepareOnRidePrerequests];
            
        }else if([event isEqualToString:@"ride-canceled"]){
            [self handleCancelRideBySystemOrDriver:1];
            
        }else if([event isEqualToString:@"ride-auto-canceled"]){
            [self handleCancelRideBySystemOrDriver:2];
            _rideStatusLabel.text = NSLocalizedString(@"PCC_headet_title_canceled", @"");
            
        }else if([event isEqualToString:@"ride-dropoff-location-changed"]){
            [self prepareOnRidePrerequests];
        }else if([event isEqualToString:@"ride-fee-applied"]){
            
        }else if([event isEqualToString:@"driver-eta"]){
            if(([[_rideData objectForKey:@"status"] isEqualToString:@"accepted"]) || ([[_rideData objectForKey:@"status"] isEqualToString:@"nearby"])){
                if([message objectForKey:@"data"]){
                    if([[message objectForKey:@"data"] objectForKey:@"eta"]){
                        driverMarker.title = [NSString stringWithFormat:@"%@ Minutes", [[[message objectForKey:@"data"] objectForKey:@"eta"] stringValue]];
                        driverMarker.snippet = @"Away From You";
                        _mapView.selectedMarker = driverMarker;
                    }
                }
                driverMarker.infoWindowAnchor = CGPointMake(1.0, 1.0f);
            }
        }
    }
}

-(void)handleAnimationArray:(NSArray *)locations{
    if([locations count] < 8){
        [self animateExistingDriverMarkerWithLocationsArray:locations animationPeriod:5 withFinalHeading:0.0 :^(BOOL completed){}];
    }else{
        NSMutableArray *firstArray = [[NSMutableArray alloc] init];
        NSMutableArray *secondArray = [[NSMutableArray alloc] init];
        NSMutableArray *thirdArray = [[NSMutableArray alloc] init];
        
        
        for(int i = 0 ; i < [locations count] ; i++){
            if(i < ([locations count]/3))
                [firstArray addObject:[locations objectAtIndex:i]];
            else{
                if(i < ([locations count]*2/3))
                    [secondArray addObject:[locations objectAtIndex:i]];
                else{
                    if(i < ([locations count]))
                        [thirdArray addObject:[locations objectAtIndex:i]];
                }
            }
        }
        
        [self animateExistingDriverMarkerWithLocationsArray:[firstArray copy] animationPeriod:5/3 withFinalHeading:0.0 :^(BOOL completed){
            
            if(completed){
                [self animateExistingDriverMarkerWithLocationsArray:[secondArray copy] animationPeriod:5/3 withFinalHeading:0.0 :^(BOOL completed){
                    
                    if(completed){
                        [self animateExistingDriverMarkerWithLocationsArray:[thirdArray copy] animationPeriod:5/3 withFinalHeading:0.0 :^(BOOL completed){}];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Animate driver marker after receiving new location

-(void)animateExistingDriverMarkerWithLocationsArray:(NSArray *)locations animationPeriod:(float)period withFinalHeading:(float)heading :( void (^)(BOOL))completion{
    if(!driverMarker.map)
        driverMarker.map = _mapView;
    
    if(locations){
        if([locations count] > 0){
            NSDictionary * previousLocation = nil;
            NSLog(@"locations : %@", locations);
            
            //First Animation, 2 seconds for rotation
            [CATransaction begin];
            [CATransaction setAnimationDuration:2];
            if(heading > 0){
                driverMarker.rotation = (heading * (180.0 / M_PI)) + 180;
            }else{
                for (NSDictionary *location in locations) {
                    if(previousLocation){
                        CLLocationCoordinate2D firstCoordi = CLLocationCoordinate2DMake([[previousLocation objectForKey:@"latitude"] floatValue], [[previousLocation objectForKey:@"longitude"] floatValue]);
                        CLLocationCoordinate2D secondCoordi = CLLocationCoordinate2DMake([[location objectForKey:@"latitude"] floatValue], [[location objectForKey:@"longitude"] floatValue]);
                        
                        double directionDegree = [HelperClass angleFromCoordinate:firstCoordi toCoordinate:secondCoordi];
                        driverMarker.rotation = (directionDegree * (180.0 / M_PI));
                    }
                    previousLocation = location;
                }
            }
            [CATransaction commit];
            //Second Animation, 5 seconds for position
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                completion(YES);
            }];
            [CATransaction setAnimationDuration:period];
            for (NSDictionary *location in locations) {
                [driverMarker setPosition:CLLocationCoordinate2DMake([[location objectForKey:@"latitude"] floatValue], [[location objectForKey:@"longitude"] floatValue])];
            }
            [CATransaction commit];
        }
    }
}

//Draw Marker First Time (after receiving message from pubnub)
-(void)drawNewDriverMarkerWithlocationCoordinates:(CLLocationCoordinate2D)locationCoordinates{
    if(driverMarker.map == nil){
        UIImage *carImage = [UIImage imageNamed:@"3dCar.png"];
        driverMarker = [GMSMarker markerWithPosition:locationCoordinates];
        driverMarker.icon = carImage;//[UIImage imageWithData:UIImagePNGRepresentation(carImage) scale:20/zoom];
        if(_driverData && !([_driverData isKindOfClass:[NSNull class]])){
            NSString *heading = [NSString stringWithFormat:@"%@", [_driverData objectForKey:@"lastLocationHeading"]];
            if(heading.length > 0)
                driverMarker.rotation = ([heading floatValue] * (180.0 / M_PI)) + 180;
        }
        driverMarker.groundAnchor = CGPointMake(0.75, 0.5);
        driverMarker.appearAnimation = kGMSMarkerAnimationPop;
        driverMarker.tracksViewChanges = NO;
        driverMarker.flat = YES;
        driverMarker.map = _mapView;
    }
}

#pragma mark - MapView Zoom
- (void) mapView: (GMSMapView *)mapView didChangeCameraPosition: (GMSCameraPosition *)position
{
    if([driverMarker isKindOfClass:[GMSMarker class]]){
        float zoom = mapView.camera.zoom;
        UIImage *img = driverMarker.icon;
        driverMarker.icon = [UIImage imageWithData:UIImagePNGRepresentation(img) scale:21/zoom];
    }
}

#pragma mark - Cancel Ride Request
-(void)cancelRideInBackground:(NSDictionary *)cancelDictionary{
    @autoreleasepool {
        NSDictionary *parameters = @{
                                     @"cancellationReason" : [cancelDictionary objectForKey:@"cancellationReason"] ? [cancelDictionary objectForKey:@"cancellationReason"] : @"",
                                     @"currentLocation" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f",_applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f",_applicationDelegate.currentLocation.coordinate.longitude], nil]
                                     };
        NSLog(@"will cancel with parameters : %@", parameters);
        [RidesServiceManager cancelRideRequest:parameters andRideID:[cancelDictionary objectForKey:@"rideID"] :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishCancelRide:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishCancelRide:(NSDictionary *)response{
    NSLog(@"finishCancelRide response : %@", response);
    [self showLoadingView:NO];
    if([[response objectForKey:@"code"] intValue] == 200){
        if(response){
            if([response objectForKey:@"data"]){
                _rideData = [response objectForKey:@"data"];
                if(([[_rideData objectForKey:@"status"] isEqualToString:@"clearance"]) || [[_rideData objectForKey:@"status"] isEqualToString:@"finished"]){
                    [self showOnRideFooterView:NO instantHide:NO];
                    [self prepareOnRidePrerequests];
                }else{
                    if([response objectForKey:@"client"]){
                        [ServiceManager saveLoggedInClientData:[response objectForKey:@"client"] andAccessToken:nil];
                        if([[[response objectForKey:@"client"] objectForKey:@"isOnRide"] intValue] == 1){
                            [self prepareOnRidePrerequests];
                        }else{
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    }
                }
            }else
                [self prepareOnRidePrerequests];
        }else
            [self prepareOnRidePrerequests];
    }else{
        [self prepareOnRidePrerequests];
    }
    
}

#pragma mark - Finally, Validate ride request parameters
-(BOOL)validateRideRequestParameters{
    if(![_rideData objectForKey:@"category"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_cat_title", @"") andMessage:NSLocalizedString(@"MFC_missing_cat_message", @"")] animated:YES completion:nil];
        return NO;
    }

    if(![_rideData objectForKey:@"pickupLocation"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_pickupLocation_title", @"") andMessage:NSLocalizedString(@"MFC_missing_pickupLocation_message", @"")] animated:YES completion:nil];
        return NO;
    }
    return YES;
}
#pragma mark - Error from server? let's validate
-(void)createRideServerValidation:(NSDictionary *)response{
    if([[response objectForKey:@"code"] intValue] == 400){
        if([[[response objectForKey:@"errors"] objectForKey:@"accessToken"] intValue] == 1){
            [self presentViewController:[HelperClass showAlert:@"Not Authorized" andMessage:@"No logged in user"] animated:YES completion:nil];
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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

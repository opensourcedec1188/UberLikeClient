//
//  MapFromViewController.m
//  Ego
//
//  Created by MacBookPro on 4/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface HomeViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@property (nonatomic) Reachability *internetReachability;
@end

@implementation HomeViewController

#pragma mark - Network Error Work

-(void)hideNetworkErrorView{
    [self showNetworkError:NO];
}

-(void)showNetworkError:(BOOL)show{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    if(show){
        if(!networkErrorShown){
            [_networkErorView removeFromSuperview];
            _networkErorView = nil;
            _networkErorView = [[NetworkErrorView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 64)];
            _networkErorView.tag = 100;
            _networkErorView.delegate = self;
            [window addSubview:_networkErorView];
            [window bringSubviewToFront:_networkErorView];
            
            _containerTopConst.constant = _containerTopConst.constant + 64;
            
            [UIView animateWithDuration:0.4f
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _networkErorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
                                 [self.view layoutIfNeeded];
                             } completion:^(BOOL finished){}];
        }
    }else{
        if(_containerTopConst.constant > 54){
            _containerTopConst.constant = _containerTopConst.constant - 64;
            [UIView animateWithDuration:0.4f
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _networkErorView.frame = CGRectMake(0, -64, self.view.frame.size.width, 64);
                                 [self.view layoutIfNeeded];
                                 [_mainContainerView layoutIfNeeded];
                             } completion:^(BOOL finished){
                                 for(UIView *subview in [window subviews]){
                                     if(subview.tag == 100)
                                         [subview removeFromSuperview];
                                 }
                                 _networkErorView = nil;
                             }];
        }
    }
    networkErrorShown = show;
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    if(!((long)curReach.currentReachabilityStatus == 0)){
        [self hideNetworkErrorView];
        NSDictionary *nearbyParams = @{@"location" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.longitude], nil], @"language" : [HelperClass getDeviceLanguage]};
        
        [self performSelectorInBackground:@selector(getNearbyPlaces:) withObject:nearbyParams];
    }else{
        [self showNetworkError:YES];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    if(![HelperClass checkNetworkReachability])
        [self showNetworkError:YES];
    
    currentMode = 1;
    networkErrorShown = NO;
    fullCardsShown = NO;
    selectedCategoryType = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationController.delegate = self;
    
    _applicationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Adjusting Pin Selection Frame
    self.pinImageView.frame = CGRectMake((_mainContainerView.frame.size.width/2) - (self.pinImageView.frame.size.width/2), (_mainContainerView.frame.size.height/2) - (self.pinImageView.frame.size.height), self.pinImageView.frame.size.width, self.pinImageView.frame.size.height);
    self.title = @"بسم الله";
    
    _rideParametersDictionary = [[NSMutableDictionary alloc] init];
    
    surroundDriversArray = [[NSMutableArray alloc] init];
    
    [self addLeftMenuView];
    menuShown = NO;
    leftMenuBGGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMe)];
    
    [self setMapParams];
    
    UIBezierPath *destShadowPath = [UIHelperClass setViewShadow:_destinationView edgeInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) andShadowRadius:25.0f];
    _destinationView.layer.shadowPath = destShadowPath.CGPath;
    
    _mainContainerView.clipsToBounds = YES;
    
    _confirmModeLeftConst.constant = self.view.frame.size.width;
    _confirmModeRightConst.constant = -self.view.frame.size.width;
    [_mainContainerView layoutIfNeeded];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)setMapParams{
    GMSCameraPosition *mapViewCamera = [GMSCameraPosition cameraWithLatitude:self.applicationDelegate.currentLocation.coordinate.latitude
                                                                   longitude:self.applicationDelegate.currentLocation.coordinate.longitude
                                                                        zoom:14.3f];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [_mapView setCamera:mapViewCamera];
    //Map Style
    GMSMapStyle *style = [RidesServiceManager setMapStyleFromFileName:@"style"];
    if(style)
        [_mapView setMapStyle:style];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self deregisterForKeyboardNotifications];
    [_pupnubManager endListening];
    _pupnubManager = nil;
    
    [_nearByDriversTimer invalidate];
    _nearByDriversTimer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"In the name of allah";    
    //Surround drivers
    [self setTimerForNearbyDrivers];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    if([[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"isOnRide"] intValue] == 1){
        [self performSegueWithIdentifier:@"goOnRideScreen" sender:self];
    }else if ([[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"lastRideMessage"] isEqualToString:@"not-rated"]) {
        [self convertToCategorySelectionMode:NO];
        ratingView = [[RatingCustomView alloc] initWithFrame:_mainContainerView.frame];
        ratingView.delegate = self;
        ratingView.alpha = 0.0f;
        [_mainContainerView addSubview:ratingView];
        [UIView animateWithDuration:0.4f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             ratingView.alpha = 1.0f;
                         } completion:^(BOOL finished){}];
    }
    
    if(_applicationDelegate.stringFromShareExtension.length > 0)
        [self appOpenedFromShareExtension];
    
    favouritesArray = [HelperClass getFavouritesFromClient];
    
    _downsideContainerView.delegate = self;
    _confirmSelectModeView.delegate = self;
    if([HelperClass checkNetworkReachability]){
        NSDictionary *nearbyParams = @{@"location" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.longitude], nil], @"language" : [HelperClass getDeviceLanguage]};
        
        [self performSelectorInBackground:@selector(getNearbyPlaces:) withObject:nearbyParams];
    }
}

-(void)enterForeground{
    if(_applicationDelegate.stringFromShareExtension.length > 0)
        [self appOpenedFromShareExtension];
}

-(void)appOpenedFromShareExtension{
    NSLog(@"appOpenedFromShareExtension : %@", _applicationDelegate.stringFromShareExtension);
    [GoogleServicesManager getCoordinatesFromSharedString:_applicationDelegate.stringFromShareExtension :^(NSArray *returnArray){
        NSLog(@"appOpenedFromShareExtension : %@", returnArray);
        if(returnArray && ([returnArray count] > 1)){
            CLLocationCoordinate2D sharedCoordinates = CLLocationCoordinate2DMake([[returnArray objectAtIndex:0] floatValue], [[returnArray objectAtIndex:1] floatValue]);
            [GoogleServicesManager getAddressFromCoordinates:sharedCoordinates.latitude andLong:sharedCoordinates.longitude :^(NSDictionary *response){
                
                NSArray *destinationArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [[returnArray objectAtIndex:0] floatValue]], [NSString stringWithFormat:@"%f", [[returnArray objectAtIndex:1] floatValue]], nil];
                NSDictionary *dropOffLoc = @{@"coordinates" : destinationArray, @"type" : @"Point"};
                [_rideParametersDictionary setObject:dropOffLoc forKey:@"dropoffLocation"];
                
                NSDictionary *pickupLocation = @{
                                                 @"coordinates" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.longitude], nil],
                                                 @"type" : @"Point"
                                                 };
                
                self.destinationAboveLabel.text = [response objectForKey:@"address"];
                
                [self getEstimationForPickupLocation:pickupLocation];
                
                [self setDropOffMarkerToLocation:CLLocationCoordinate2DMake([[[dropOffLoc objectForKey:@"coordinates"] objectAtIndex:0] doubleValue], [[[dropOffLoc objectForKey:@"coordinates"] objectAtIndex:1] doubleValue]) andTitle:[response objectForKey:@"address"]];
                [self performSelectorInBackground:@selector(getGoogleAPIPathForRide) withObject:nil];
                
                [self moveToVehicleType];
            }];
        }
    }];
}

#pragma mark - Add Side Menu
-(void)addLeftMenuView{
    _leftMenuView.delegate = self;

    [self.view bringSubviewToFront:_leftMenuView];
    [self.view bringSubviewToFront:_mainContainerView];
}

-(void)performSegue:(NSString *)segueIdentifier{
    [self performSegueWithIdentifier:segueIdentifier sender:self];
}

-(void)presentViewController:(NSString *)storyboardID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Client" bundle:nil];
    UIViewController *theInitialViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    [self presentViewController:theInitialViewController animated:YES completion:nil];
}

-(void)hideMe{
    [self showSideMenuView:NO];
}

-(void)showSideMenuView:(BOOL)show{
    [_leftButton setEnabled:NO];
//    [self showMapBellowDone:NO];
    if(show){
        if(!menuShown){
            [_leftMenuBG removeFromSuperview];
            _leftMenuBG = [[UIView alloc] initWithFrame:_mainContainerView.bounds];
            _leftMenuBG.backgroundColor = [UIColor blackColor];
            _leftMenuBG.alpha = 0.0;
            [_mainContainerView addSubview:_leftMenuBG];
            
            _containerTopConst.constant = _containerTopConst.constant + 54;
            _containerBtmConst.constant = _containerBtmConst.constant + 54;
            _containerLeftConst.constant = _leftMenuView.frame.size.width;
            _containerRightConst.constant = -_leftMenuView.frame.size.width;
            
            _leftMenuBG.hidden = NO;
            [_leftMenuBG removeGestureRecognizer:leftMenuBGGesture];
            [_leftMenuBG addGestureRecognizer:leftMenuBGGesture];
            [UIView animateWithDuration:0.6f
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _leftMenuBG.alpha = 0.1;
                                 _mainContainerView.layer.cornerRadius = 6.0f;
                                 [self.view layoutIfNeeded];
                             } completion:^(BOOL finished){
                                 [_leftButton setEnabled:YES];
                                 menuShown = show;
                             }];
        }
    }else{
        if(menuShown){
            _containerTopConst.constant = _containerTopConst.constant - 54;
            _containerBtmConst.constant = _containerBtmConst.constant - 54;
            _containerLeftConst.constant = 0;
            _containerRightConst.constant = 0;
            _leftManuSideConst.constant = 0;

            [UIView animateWithDuration:0.6f
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _leftMenuBG.alpha = 0.0f;
                                 _mainContainerView.layer.cornerRadius = 0.0f;
                                 [self.view layoutIfNeeded];
                                 [_mainContainerView layoutIfNeeded];
                             } completion:^(BOOL finished){
                                 [_leftMenuBG removeFromSuperview];
                                 [_leftButton setEnabled:YES];
                                 menuShown = show;
                             }];
        }
    }
}

#pragma mark - Left Menu Btn Action
- (IBAction)leftMenuBtnAction:(UIButton *)sender {
    [self showSideMenuView:!menuShown];
}

#pragma mark - Get nearby Places
-(void)getNearbyPlaces:(NSDictionary *)params{
    [RidesServiceManager getNearbyPleaces:params :^(NSDictionary *response){
        [self performSelectorOnMainThread:@selector(finishGetNearbyPlaces:) withObject:response waitUntilDone:NO];
    }];
}

-(void)finishGetNearbyPlaces:(NSDictionary *)response{
    [self performSelectorInBackground:@selector(getRecentPlaces) withObject:nil];
    if(response){
        if([response objectForKey:@"places"]){
            nearByPlacesArray = [response objectForKey:@"places"];
            _downsideContainerView.nearByPlacesArray = nearByPlacesArray;
        }
    }
}

#pragma mark - Get Recent Places
-(void)getRecentPlaces{
    @autoreleasepool {
        [RidesServiceManager getRecentPlaces: ^(NSDictionary * response){
            [self performSelectorOnMainThread:@selector(finishGetRecentPlaces:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetRecentPlaces:(NSDictionary *)response{
    if(response){
        if([response objectForKey:@"places"]){
            recentPlacesArray = [response objectForKey:@"places"];
            _downsideContainerView.recentPlacesArray = recentPlacesArray;
        }
    }
}


#pragma mark - Rating View
-(void)dismissRatingView:(BOOL)sucess{
    [UIView animateWithDuration:0.4f
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         ratingView.alpha = 0.0f;
                     } completion:^(BOOL finished){
                         [ratingView removeFromSuperview];
                     }];
}

#pragma mark - Nearby drivers
-(void)setTimerForNearbyDrivers{
    [self performSelectorInBackground:@selector(getNearbyDriversChannelsInBackground) withObject:nil];
    [_nearByDriversTimer invalidate];
    _nearByDriversTimer = nil;
    _nearByDriversTimer = [NSTimer scheduledTimerWithTimeInterval:15
                                                           target:self
                                                         selector:@selector(fetchUpdatedNearbyDrivers)
                                                         userInfo:nil
                                                          repeats:YES];
}
-(void)fetchUpdatedNearbyDrivers{
    [self performSelectorInBackground:@selector(getNearbyDriversChannelsInBackground) withObject:nil];
}


- (void)deregisterForKeyboardNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - subscribe to drivers surround

-(void)getNearbyDriversChannelsInBackground{
    @autoreleasepool {
        NSDictionary *params = @{
                            @"currentLocation" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f",self.applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f",self.applicationDelegate.currentLocation.coordinate.longitude], nil]
                            };
        [RidesServiceManager getNearByDriversPupnubChannels:params :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishGetNearbyChannels:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishGetNearbyChannels:(NSDictionary *)response{
    
    if([[response objectForKey:@"code"] intValue] == 200){
        if([response objectForKey:@"nearbyDrivers"]){
            NSArray *drivers = [response objectForKey:@"nearbyDrivers"];
            int currentCategory = (selectedCategoryType > 0) ? selectedCategoryType : 1;
            if([drivers count] > 0){
                if([surroundDriversArray count] > 0){
                    
                    NSMutableArray *newSurroundDrivers = [HelperClass removeNotExistingObjects:surroundDriversArray andNewArray:drivers];
                    surroundDriversArray = newSurroundDrivers;
                    
                    [self reDrawDrivers:currentCategory];
                }else{
                    surroundDriversArray = [drivers mutableCopy];
                    [self reDrawDrivers:currentCategory];
                }
            }else{
                [self emptyMap:^(BOOL finished){}];
            }
            
            //Listen to new drivers channels array
            
            
        }else
            [self emptyMap:^(BOOL finished){}];
        
    }else
        [self emptyMap:^(BOOL finished){}];
}

-(void)reDrawDrivers:(int)currentCategory{
    [self listenToPubnubArrayChannels];
    NSArray *array = [[NSArray alloc] initWithArray:surroundDriversArray];
    for(int i = 0 ; i < [array count] ; i++){
        NSDictionary *driver = [array objectAtIndex:i];
        
        
        if([[driver objectForKey:@"category"] isEqualToString:[HelperClass getCatFromIntSelectionForWebService:currentCategory]]){
            GMSMarker *marker = [driver objectForKey:@"marker"];
            BOOL draw = NO;
            if((([marker isKindOfClass:[GMSMarker class]]) && (marker.map == nil)))
                draw = YES;
            if(!([marker isKindOfClass:[GMSMarker class]]) || !marker)
                draw = YES;
            if(draw){
                NSLog(@"should draw driver : %@", driver);
                if([HelperClass checkArray:[driver objectForKey:@"currentLocation"]]){
                    CLLocationCoordinate2D newLocation = CLLocationCoordinate2DMake([[[driver objectForKey:@"currentLocation"] objectAtIndex:0] floatValue], [[[driver objectForKey:@"currentLocation"] objectAtIndex:1] floatValue]);
                    marker = [self drawNewDrvierMarker:marker andlocationCoordinates:newLocation andHeading:@""];
                    
                    [surroundDriversArray replaceObjectAtIndex:i withObject:@{@"marker" : marker, @"channel" : [driver objectForKey:@"channel"], @"currentLocation" : [driver objectForKey:@"currentLocation"], @"drawn" : @"", @"heading" : [driver objectForKey:@"heading"] ? [driver objectForKey:@"heading"] : @"", @"category" : [driver objectForKey:@"category"]}];
                    NSLog(@"reDrawDrivers surroundDriversArray : %@", surroundDriversArray);
                }
            }
        }else{
            GMSMarker *marker = [driver objectForKey:@"marker"];
            if(([marker isKindOfClass:[GMSMarker class]])){
                marker.map = nil;
            }
        }
    }
}

-(void)listenToPubnubArrayChannels{
    NSMutableArray *arrayForPubnub = [[NSMutableArray alloc] init];
    int currentCategory = (selectedCategoryType > 0) ? selectedCategoryType : 1;
    for (NSDictionary *driver in surroundDriversArray) {
        if([[driver objectForKey:@"category"] isEqualToString:[HelperClass getCatFromIntSelectionForWebService:currentCategory]]){
            NSString *channelName = [driver objectForKey:@"channel"];
            if(channelName && (channelName.length > 0))
                [arrayForPubnub addObject:[driver objectForKey:@"channel"]];
        }
    }
    if([arrayForPubnub isKindOfClass:[NSMutableArray class]]){
        if([arrayForPubnub count] > 0){
            if(!_pupnubManager){
                _pupnubManager = [[PupnubRideManager alloc] initForNearByWithChannelsArray:arrayForPubnub];
                _pupnubManager.listnerDelegate = self;
            }else{
                [_pupnubManager endListening];
                [_pupnubManager listenToNearbyDrivers:arrayForPubnub];
            }
        }
    }
}

#pragma mark - Empty map from all nearby drivers
-(void)emptyMap :( void (^)(BOOL))completion{
    if([surroundDriversArray count] > 0){
        for (int i = 0; i < [surroundDriversArray count]; i++) {
            NSDictionary *driver = [surroundDriversArray objectAtIndex:i];
            GMSMarker *driverMarker = [driver objectForKey:@"marker"];
            if([driverMarker isKindOfClass:[GMSMarker class]]){
                driverMarker.map = nil;
            }
        }
    }
    completion(YES);
}

#pragma mark - Received new location from a nearby driver
-(void)receivedMessageFromDriverOnPupnub:(NSDictionary *)message {
    NSLog(@"pubnub message : %@", message);
    if(message){
        for (int i = 0; i < [surroundDriversArray count]; i++) {
            NSDictionary *driver = [surroundDriversArray objectAtIndex:i];
            if([[driver objectForKey:@"channel"] isEqualToString:[message objectForKey:@"channel"]]){
                int currentCategory = (selectedCategoryType > 0) ? selectedCategoryType : 1;
                
                if([[driver objectForKey:@"category"] isEqualToString:[HelperClass getCatFromIntSelectionForWebService:currentCategory]]){
                    CLLocationCoordinate2D newLocationCoordinates = CLLocationCoordinate2DMake([[[[[message objectForKey:@"locationInfo"] objectForKey:@"locations"] lastObject] objectForKey:@"latitude"] floatValue], [[[[[message objectForKey:@"locationInfo"] objectForKey:@"locations"] lastObject] objectForKey:@"longitude"] floatValue]);
                    
                    GMSMarker *driverMarker = [driver objectForKey:@"marker"];
                    
                    if([driverMarker isKindOfClass:[GMSMarker class]]){
                        if([[message objectForKey:@"locationInfo"] isKindOfClass:[NSDictionary class]]){
                            if([[message objectForKey:@"locationInfo"] objectForKey:@"locations"]){
                                NSArray *locationsArray = [[message objectForKey:@"locationInfo"] objectForKey:@"locations"];
                                if(locationsArray.count > 0)
                                    [self handleAnimationArray:locationsArray andMarker:driverMarker andDriver:driver andNewLocation:newLocationCoordinates andOldArrayIndex:i];
                            }
                        }
                    }else{
                        driverMarker = [self drawNewDrvierMarker:driverMarker andlocationCoordinates:newLocationCoordinates andHeading:[NSString stringWithFormat:@"%f", [[[message objectForKey:@"locationInfo"] objectForKey:@"heading"] floatValue]]];
                        id lastLocation = [[[message objectForKey:@"locationInfo"] objectForKey:@"locations"] lastObject];
                        [surroundDriversArray replaceObjectAtIndex:i withObject:@{@"marker" : driverMarker, @"channel"  : [driver objectForKey:@"channel"], @"currentLocation" : [NSArray arrayWithObjects:[lastLocation objectForKey:@"latitude"], [lastLocation objectForKey:@"longitude"], nil], @"drawn" : @"yes", @"haeding" : [driver objectForKey:@"heading"] ? [driver objectForKey:@"heading"] : @"", @"category" : [driver objectForKey:@"category"]}];
                        NSLog(@"receivedMessageFromDriverOnPupnub surroundDriversArray : %@", surroundDriversArray);
                    }
                }
            }
        }
    }
}

-(void)handleAnimationArray:(NSArray *)locations andMarker:(GMSMarker *)marker andDriver:(NSDictionary *)driver andNewLocation:(CLLocationCoordinate2D)newLocationCoordinates andOldArrayIndex:(int)i{
    GMSMarker *driverMarker = marker;
    if([locations count] < 6){
        [self animateExistingDriverMarker:driverMarker andLocationsArray:locations animationPeriod:5 withFinalHeading:0.0 andDriverObject:driver andIndexInDriversArray:i :^(GMSMarker *returnedMarker){}];
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
        
        [self animateExistingDriverMarker:driverMarker andLocationsArray:[firstArray copy] animationPeriod:6/3 withFinalHeading:0.0 andDriverObject:driver andIndexInDriversArray:i :^(GMSMarker *returnedMarker){
            if(returnedMarker){
                [self animateExistingDriverMarker:driverMarker andLocationsArray:[secondArray copy] animationPeriod:6/3 withFinalHeading:0.0 andDriverObject:driver andIndexInDriversArray:i :^(GMSMarker *returnedMarker){
                    if(returnedMarker){
                        [self animateExistingDriverMarker:driverMarker andLocationsArray:[thirdArray copy] animationPeriod:6/3 withFinalHeading:0.0 andDriverObject:driver andIndexInDriversArray:i :^(GMSMarker *returnedMarker){}];
                    }
                }];
            }
        }];
    }
    /*FOR NEW TRACKING (MOVIEONE)*/
//    if(locations && ([locations count] > 0))
//        [self animateExistingDriverMarker:driverMarker andLocationsArray:locations animationPeriod:6 withFinalHeading:0.0 andDriverObject:driver andIndexInDriversArray:i :^(GMSMarker *returnedMarker){}];
}

#pragma mark - Animate driver marker after receiving new location

-(void)animateExistingDriverMarker:(GMSMarker *)driverMarker andLocationsArray:(NSArray *)locations animationPeriod:(float)period withFinalHeading:(float)heading andDriverObject:(NSDictionary *)driver andIndexInDriversArray:(int)i  :( void (^)(GMSMarker *))completion{
    if((driverMarker.map != _mapView) && ([[driver objectForKey:@"category"] isEqualToString:[HelperClass getCatFromIntSelectionForWebService:selectedCategoryType]]))
        driverMarker.map = _mapView;
    if(locations){
        if([locations count] > 0){
            NSDictionary * previousLocation = nil;
            
            //First Animation, 3 seconds for rotation
            [CATransaction begin];
            [CATransaction setAnimationDuration:period];
            for (NSDictionary *location in locations) {
                if(previousLocation){
                    
                    CLLocationCoordinate2D firstCoordi = CLLocationCoordinate2DMake([[previousLocation objectForKey:@"latitude"] floatValue], [[previousLocation objectForKey:@"longitude"] floatValue]);
                    CLLocationCoordinate2D secondCoordi = CLLocationCoordinate2DMake([[location objectForKey:@"latitude"] floatValue], [[location objectForKey:@"longitude"] floatValue]);
                    
                    double directionDegree = [HelperClass angleFromCoordinate:firstCoordi toCoordinate:secondCoordi];
                    driverMarker.rotation = (directionDegree * (180.0 / M_PI));
                }
                previousLocation = location;
            }
            [CATransaction commit];

            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                if(surroundDriversArray && (surroundDriversArray.count > 0)){
                    if([surroundDriversArray objectAtIndex:i]){
                        id lastLocation = [locations lastObject];
                        [surroundDriversArray replaceObjectAtIndex:i withObject:@{@"marker" : driverMarker, @"channel"  : [driver objectForKey:@"channel"], @"currentLocation" : [NSArray arrayWithObjects:[lastLocation objectForKey:@"latitude"], [lastLocation objectForKey:@"longitude"], nil], @"drawn" : @"yes", @"haeding" : [driver objectForKey:@"heading"] ? [driver objectForKey:@"heading"] : @"", @"category" : [driver objectForKey:@"category"]}];
                    }
                }
                
                completion(driverMarker);
            }];
            [CATransaction setAnimationDuration:period];
            for (NSDictionary *location in locations) {
                [driverMarker setPosition:CLLocationCoordinate2DMake([[location objectForKey:@"latitude"] floatValue], [[location objectForKey:@"longitude"] floatValue])];
            }
            [CATransaction commit];
        }
    }
}

#pragma mark - If no marker, Draw marker for this driver
-(GMSMarker *)drawNewDrvierMarker:(GMSMarker *)driverMarker andlocationCoordinates:(CLLocationCoordinate2D)locationCoordinates andHeading:(NSString *)heading{
    float zoom = _mapView.camera.zoom;
    UIImage *carImage = [UIImage imageNamed:@"3dCar.png"];
    driverMarker = [GMSMarker markerWithPosition:locationCoordinates];
    driverMarker.icon = [UIImage imageWithData:UIImagePNGRepresentation(carImage) scale:21/zoom];

    if(heading.length > 0)
        driverMarker.rotation = ([heading floatValue] * (180.0 / M_PI)) + 180;
    driverMarker.iconView.backgroundColor = [UIColor yellowColor];
    
    driverMarker.groundAnchor = CGPointMake(0.75, 0.5);
    driverMarker.appearAnimation = kGMSMarkerAnimationPop;
    driverMarker.tracksViewChanges = NO;
    driverMarker.flat = YES;
    driverMarker.map = _mapView;
    
    return driverMarker;
    
}

#pragma - mark Mapview Delegate
- (void) mapView: (GMSMapView *)mapView
didChangeCameraPosition: (GMSCameraPosition *)position
{
    float zoom = mapView.camera.zoom;
    if([surroundDriversArray count] > 0){
        for (int i = 0; i < [surroundDriversArray count]; i++) {
            NSDictionary *channel = [surroundDriversArray objectAtIndex:i];
            if(channel){
                if([[channel objectForKey:@"marker"] isKindOfClass:[GMSMarker class]]){
                    
                    GMSMarker *driverMarker = [channel objectForKey:@"marker"];
                    UIImage *img = driverMarker.icon;
                    driverMarker.icon = [UIImage imageWithData:UIImagePNGRepresentation(img) scale:21/zoom];
                }
            }
        }
    }
}


#pragma mark - Animate map to user current location
- (IBAction)myLocationButton:(UIButton *)sender {
    CLLocation *location = _mapView.myLocation;
    if (location) {
        [_mapView animateToLocation:location.coordinate];
    }
}

#pragma mark - TextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}




#pragma mark
#pragma mark - dropOff Marker
-(void)setDropOffMarkerToLocation:(CLLocationCoordinate2D)location andTitle:(NSString *)title {
    dropOffMarker.map = nil;
    dropOffMarker = nil;
    dropOffMarker = [[GMSMarker alloc] init];
    dropOffMarker.position = location;
    dropOffMarker.title = title;
    dropOffMarker.snippet = title;
    UIImage *markerIcon = [UIImage imageNamed:@"dropOffMarker"];
    markerIcon = [markerIcon imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, (markerIcon.size.width/2), (markerIcon.size.height/2), 0)];
    dropOffMarker.icon = markerIcon;
    dropOffMarker.map = _mapView;
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:location zoom:15];
    [_mapView animateWithCameraUpdate:updatedCamera];
}


#pragma mark - Show Map Bellow Done Button
/*
 forSelection
 0: selecting destination location pin on map
 */
-(void)showMapBellowDone:(BOOL)show{
    
    if(show) {
        [_mainContainerView bringSubviewToFront:self.pinImageView];
        [self showFullDownsideView:NO withHeight:_downsideContainerView.smallCardsContainerView.frame.size.height + _downsideContainerView.smallCardsContainerView.frame.origin.y];
        
        if([_rideParametersDictionary objectForKey:@"dropoffLocation"]){
            if([HelperClass checkCoordinates:[_rideParametersDictionary objectForKey:@"dropoffLocation"]]){
                [_mapView animateToLocation:CLLocationCoordinate2DMake([[[[_rideParametersDictionary objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[[_rideParametersDictionary objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue])];
                [_mapView animateToZoom:18];
            }
        }
        _mapBellowDoneButton.frame = CGRectMake(_mapBellowDoneButton.frame.origin.x, self.view.frame.size.height, _mapBellowDoneButton.frame.size.width, _mapBellowDoneButton.frame.size.height);
        _downsideBtmConstraint.constant = -_downsideContainerView.frame.size.height;
        [UIView animateWithDuration:0.4f
                              delay: 0.0
                            options: UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [_mapBellowDoneButton setHidden:NO];
                             _mapBellowDoneButton.frame = CGRectMake(_mapBellowDoneButton.frame.origin.x, self.view.frame.size.height - _mapBellowDoneButton.frame.size.height - 15, _mapBellowDoneButton.frame.size.width, _mapBellowDoneButton.frame.size.height);
                             [self.pinImageView setHidden:NO];
                             [_mapBellowCancelBtn setHidden:NO];
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished){}];
    }else{
        _downsideBtmConstraint.constant = 0;
        [_mapBellowDoneButton setHidden:YES];
        [UIView animateWithDuration:0.4f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _mapBellowDoneButton.frame = CGRectMake(_mapBellowDoneButton.frame.origin.x, self.view.frame.size.height, _mapBellowDoneButton.frame.size.width, _mapBellowDoneButton.frame.size.height);
                             if(currentMode != 2){
                                 [self.view layoutIfNeeded];
                             }
                             [_mapBellowCancelBtn setHidden:YES];
                         } completion:^(BOOL finished){
                             [self.pinImageView setHidden:YES];
                         }];
    }
    
}
//Done button while selecting destination location

- (IBAction)mapBellowCancelBtnAction:(UIButton *)sender {
    [self showMapBellowDone:NO];
}

- (IBAction)mapBellowDestinationLocationAction:(UIButton *)sender {
    [GoogleServicesManager getAddressFromCoordinates:_mapView.camera.target.latitude andLong:_mapView.camera.target.longitude :^(NSDictionary *response){
        //Estimation for selected dropOff

        NSArray *destinationArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _mapView.camera.target.latitude], [NSString stringWithFormat:@"%f", _mapView.camera.target.longitude], nil];

        NSDictionary *locationData = @{@"coordinates" : destinationArray, @"type" : @"Point", @"addressString" : [response objectForKey:@"address"], @"titleString" : [response objectForKey:@"address"]};
        [self setChosenLocation:locationData];
        
    }];
    [self showMapBellowDone:NO];
}


#pragma mark - Selection (DropOff)
- (IBAction)destinationButtonAction:(UIButton *)sender {
    [self showMapBellowDone:NO];
    [self convertToCategorySelectionMode:NO];
    [self showFullDownsideView:NO withHeight:_downsideContainerView.smallCardsContainerView.frame.size.height + _downsideContainerView.smallCardsContainerView.frame.origin.y];
    chooseLocationView = [[DropOffLocationView alloc] initWithFrame:self.view.frame];
    chooseLocationView.delegate = self;
    [self.view addSubview:chooseLocationView];
}

#pragma mark - Location View Delegate Methods
-(void)dismissView{
    [chooseLocationView removeFromSuperview];
    chooseLocationView = nil;
}

-(void)showLoading:(BOOL)show{
    [self showLoadingView:show];
}

-(void)setChosenLocation:(NSDictionary *)choosedLocation{
    
    estimationsDictionary = nil;
    if([[choosedLocation objectForKey:@"map"] isEqualToString:@"yes"]){
        dropOffMarker.map = nil;
        dropOffMarker = nil;
        mainMapPolyline.map = nil;
        mainMapPolyline = nil;
        
        [self showMapBellowDone:YES];
    }else if([[choosedLocation objectForKey:@"skipped"] isEqualToString:@"yes"]){
        [self resetEstimations];
        dropOffMarker.map = nil;
        dropOffMarker = nil;
        mainMapPolyline.map = nil;
        mainMapPolyline = nil;
        
        self.destinationAboveLabel.text = NSLocalizedString(@"MFC_selectingOptions_2", @"");
        [_rideParametersDictionary setObject:@"none" forKey:@"dropoffLocation"];
        [self moveToVehicleType];
    }else if (([choosedLocation objectForKey:@"coordinates"]) && ([choosedLocation objectForKey:@"type"]) && ([choosedLocation objectForKey:@"addressString"])){
        [self resetEstimations];
        //Estimation for selected dropOff
        NSDictionary *pickupLocation = @{
                                         @"coordinates" : [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.longitude], nil],
                                         @"type" : @"Point"
                                         };
        
        self.destinationAboveLabel.text = [choosedLocation objectForKey:@"titleString"];
        
        [_rideParametersDictionary setObject:choosedLocation forKey:@"dropoffLocation"];
        
        [self getEstimationForPickupLocation:pickupLocation];
        
        [self setDropOffMarkerToLocation:CLLocationCoordinate2DMake([[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:0] doubleValue], [[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:1] doubleValue]) andTitle:[choosedLocation objectForKey:@"addressString"]];
        [self performSelectorInBackground:@selector(getGoogleAPIPathForRide) withObject:nil];
    }
    
}

-(void)goToFavouritesControllerWithType:(NSString *)type andLocation:(NSArray *)locationCoordinate{
    favouriteCoordinateForFavouritesFromDropoffView = locationCoordinate;
    selectedFavouriteToAdd = type;
    [self performSegueWithIdentifier:@"homeGoAddFavourites" sender:self];
}

#pragma mark - Get Ride Route Request
-(void)getGoogleAPIPathForRide{
//    [self enableAllBtns:NO];
    @autoreleasepool {
        NSArray *dropOffArray = nil;
        if([HelperClass checkCoordinates:[_rideParametersDictionary objectForKey:@"dropoffLocation"]])
            dropOffArray = [[_rideParametersDictionary objectForKey:@"dropoffLocation"] objectForKey:@"coordinates"];
        
        NSArray *pickupArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", _applicationDelegate.currentLocation.coordinate.longitude], nil];
        
        if(pickupArray && dropOffArray){
            [GoogleServicesManager getRouteFrom:CLLocationCoordinate2DMake(_applicationDelegate.currentLocation.coordinate.latitude, _applicationDelegate.currentLocation.coordinate.longitude) to:CLLocationCoordinate2DMake([[dropOffArray objectAtIndex:0] floatValue], [[dropOffArray objectAtIndex:1] floatValue]) :^(NSDictionary *response){
                [self performSelectorOnMainThread:@selector(finishGetRideRoute:) withObject:response waitUntilDone:NO];
            }];
        }else
            [self performSelectorOnMainThread:@selector(finishGetRideRoute:) withObject:nil waitUntilDone:NO];
    }
}

-(void)finishGetRideRoute:(NSDictionary *)response{
    if([[response objectForKey:@"status"] isEqualToString:@"OK"]){
        if([response objectForKey:@"routes"]){
            if([[response objectForKey:@"routes"] objectAtIndex:0]){
                if([[[response objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"]){
                    NSDictionary *pathsDictionary = [[[response objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"];
                    
                    mainMapPath = nil;
                    mainMapPolyline.map = nil;
                    mainMapPolyline = nil;
                    mainMapPath = [GMSMutablePath pathFromEncodedPath:[pathsDictionary objectForKey:@"points"]];
                    mainMapPolyline = [GMSPolyline polylineWithPath:mainMapPath];
                    mainMapPolyline.strokeWidth = 4;
                    mainMapPolyline.strokeColor = [UIColor grayColor];
                    mainMapPolyline.map = _mapView;
                    
                    GMSStrokeStyle *redYellow = [GMSStrokeStyle gradientFromColor:[UIColor colorWithRed:0.0/255.0f green:172.0/255.0f blue:250.0/255.0f alpha:1.0f] toColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0f]];
                    mainMapPolyline.spans = @[[GMSStyleSpan spanWithStyle:redYellow]];
                    
                    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_applicationDelegate.currentLocation.coordinate coordinate:dropOffMarker.position];
                    [_mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:150.0f]];
                }
            }
        }
    }
    [self moveToVehicleType];
}


-(void)showFullDownsideView:(BOOL)show withHeight:(float)height // 1 -> favourites // 2 -> Nearby // 3 -> Recent
{
    if(show){
        if(!fullCardsShown){
            _downViewHeightConstraint.constant = height;
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [self.view layoutIfNeeded];
                             }completion:^(BOOL finished){
                                 fullCardsShown = show;
                             }];
        }
    }else{
        if(fullCardsShown){
            _downViewHeightConstraint.constant = height;
            currentFavIndex= 0;
            
            [UIView animateWithDuration:0.4
                                  delay: 0.0
                                options: UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 [self.view layoutIfNeeded];
                             }completion:^(BOOL finished){
                                 fullCardsShown = show;
                             }];
        }
    }
}


-(void)setFavouriteAsDropOff:(int)selectedFavouriteIndex{
    NSLog(@"will select fav : %@", [favouritesArray objectAtIndex:selectedFavouriteIndex]);
    if([[favouritesArray objectAtIndex:selectedFavouriteIndex] objectForKey:@"location"]){
        NSDictionary *favourite = [favouritesArray objectAtIndex:selectedFavouriteIndex];
        NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [[[[favourite objectForKey:@"location"] objectForKey:@"coordinates"] objectAtIndex:0] floatValue]], [NSString stringWithFormat:@"%f", [[[[favourite objectForKey:@"location"] objectForKey:@"coordinates"] objectAtIndex:1] floatValue]], nil];
        NSDictionary *locationData = @{@"coordinates" : coordinatesArray, @"type" : @"Point", @"addressString" : [[favourite objectForKey:[HelperClass getDeviceLanguage]] objectForKey:@"title"], @"titleString" : [favourite objectForKey:@"englishAddress"]};
        [self setChosenLocation:locationData];
    }
}

-(void)setNearByAsDropoff:(int)selectedIndex{
    NSDictionary *favourite = [nearByPlacesArray objectAtIndex:selectedIndex];
    if(([favourite objectForKey:@"location"]) && ([favourite objectForKey:@"address"]) && (([favourite objectForKey:@"name"]))){
        NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [[[favourite objectForKey:@"location"] objectAtIndex:0] floatValue]], [NSString stringWithFormat:@"%f", [[[favourite objectForKey:@"location"] objectAtIndex:1] floatValue]], nil];
        NSDictionary *locationData = @{@"coordinates" : coordinatesArray, @"type" : @"Point", @"addressString" : [favourite objectForKey:@"address"], @"titleString" : [favourite objectForKey:@"name"]};
        [self setChosenLocation:locationData];
    }
}

-(void)setRecentAsDropoff:(int)selectedIndex{
    NSDictionary *place = [recentPlacesArray objectAtIndex:selectedIndex];
    if(([place objectForKey:@"location"]) && ([place objectForKey:@"address"])){
        NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [[[place objectForKey:@"location"] objectAtIndex:0] floatValue]], [NSString stringWithFormat:@"%f", [[[place objectForKey:@"location"] objectAtIndex:1] floatValue]], nil];
        NSDictionary *locationData = @{@"coordinates" : coordinatesArray, @"type" : @"Point", @"addressString" : [place objectForKey:@"address"], @"titleString" : [place objectForKey:@"address"]};
        [self setChosenLocation:locationData];
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
    [self performSegueWithIdentifier:@"homeGoAddFavourites" sender:self];
}

#pragma mark - Initial Estimation of trip cost
-(void)getEstimationForPickupLocation:(NSDictionary *)pickupLocation{
    NSDictionary *dropOffDictionary;
    if([_rideParametersDictionary objectForKey:@"dropoffLocation"]){
        dropOffDictionary = [_rideParametersDictionary objectForKey:@"dropoffLocation"];
    }else
        dropOffDictionary = @{@"coordinates" : @"none"};
    [RidesServiceManager requestTripEstimation:@{
                                                @"dropoffLocation" : dropOffDictionary,
                                                @"pickupLocation" : pickupLocation
                                                } :^(NSDictionary *response){
                                                    if([response objectForKey:@"data"]){
                                                        estimationsDictionary = [[NSDictionary alloc] initWithDictionary:[response objectForKey:@"data"]];
                                                        [self displayEstimation];
                                                    }
                                                }];
}

-(void)displayEstimation{
    if(estimationsDictionary){
        _confirmSelectModeView.estimationsDictionary = estimationsDictionary;
        [_confirmSelectModeView displayEstimation];
    }
}
-(void)resetEstimations{
    [_confirmSelectModeView resetEstimations];
}

#pragma mark - Selection (Category)
-(void)moveToVehicleType{
    [self convertToCategorySelectionMode:YES];
}
- (IBAction)confirmModeBackBtnAction:(UIButton *)sender {
    [self convertToCategorySelectionMode:NO];
}
-(void)convertToCategorySelectionMode:(BOOL)confirm{
    if(confirm){
//        [_destinationButton setEnabled:NO];
        currentMode = 2;
        _downsideLeftConst.constant = -self.view.frame.size.width;
        _downsideRightConstraint.constant = self.view.frame.size.width;
        
        _confirmModeLeftConst.constant = 0;
        _confirmModeRightConst.constant = 0;
        _confirmModeBtnLeftConst.constant = _catBackBtnConst.constant;
        
        [_mainContainerView bringSubviewToFront:_confirmSelectModeView];
        [_confirmModeBackBtn setHidden:NO];
        [UIView animateWithDuration:0.4
                              delay: 0.0
                            options: UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [_leftButton setHidden:YES];
                             [_mainContainerView layoutIfNeeded];
                         }completion:^(BOOL finished){
                             if(selectedCategoryType > 0)
                                 [_confirmSelectModeView moveCategoryIndicatorView:selectedCategoryType];
                         }];
    }else{
        [_destinationButton setEnabled:YES];
        currentMode = 1;
        dropOffMarker.map = nil;
        dropOffMarker = nil;
        mainMapPolyline.map = nil;
        mainMapPolyline = nil;
        _destinationAboveLabel.text = NSLocalizedString(@"MFC_dropOff", @"");
        [_mapView animateToZoom:14.3f];
        
        _downsideLeftConst.constant = 0;
        _downsideRightConstraint.constant = 0;
        
        _confirmModeLeftConst.constant = self.view.frame.size.width;
        _confirmModeRightConst.constant = -self.view.frame.size.width;
        _confirmModeBtnLeftConst.constant = self.view.frame.size.width;
        [_confirmModeBackBtn setHidden:YES];
        [UIView animateWithDuration:0.4
                              delay: 0.0
                            options: UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [_mainContainerView layoutIfNeeded];
                             [_leftButton setHidden:NO];
                         }completion:^(BOOL finished){}];
    }
    
    
}

-(void)setSelectedCategory:(int)selectedCat{
    selectedCategoryType = selectedCat;
}

-(void)showPaymentView{
    [paymentView removeFromSuperview];
    paymentView = [[PaymentSelectView alloc] initWithFrame:self.view.bounds];
    paymentView.delegate = self;
    [self.view addSubview:paymentView];
    
    [self.view addConstraint:[NSLayoutConstraint
                         constraintWithItem:paymentView
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.view
                         attribute:NSLayoutAttributeTop
                         multiplier:1.0
                         constant:0.0]];
    
}

-(void)dismissPaymentView{
    [paymentView removeFromSuperview];
}

#pragma mark - Finished Ride Params
-(void)goToConfirm{
    if([HelperClass checkNetworkReachability]){
        NSArray *currentLocationLocationArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", self.applicationDelegate.currentLocation.coordinate.longitude], nil];
        NSDictionary *currentLoc = @{@"coordinates" : currentLocationLocationArray, @"type" : @"Point"};
        [_rideParametersDictionary setObject:currentLoc forKey:@"currentLocation"];
        
        if([self validateRideRequestParameters])
            [self performSegueWithIdentifier:@"goConfirmRideSegue" sender:self];
        else
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC-incompleteRideParams_title", @"") andMessage:NSLocalizedString(@"incompleteRideParams_message", @"")] animated:YES completion:nil];
    }else{
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"network_problem_title", @"") andMessage:NSLocalizedString(@"network_problem_message", @"")] animated:YES completion:nil];
    }
}

#pragma mark - Finally, Validate ride request parameters
-(BOOL)validateRideRequestParameters{
    if(![_rideParametersDictionary objectForKey:@"currentLocation"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_currentLoc_title", @"") andMessage:NSLocalizedString(@"MFC_missing_currentLoc_message", @"")] animated:YES completion:nil];
        return NO;
    }
    if(![_rideParametersDictionary objectForKey:@"dropoffLocation"]){
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"MFC_missing_dropoffLocation_title", @"") andMessage:NSLocalizedString(@"MFC_missing_dropoffLocation_message", @"")] animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goConfirmRideSegue"]) {
        // Destination VC
        PickupConfirmationViewController *pickupConfirm = [segue destinationViewController];
        // Pass ride parameters to VC
        if([estimationsDictionary objectForKey:[HelperClass getCatFromIntSelectionForWebService:selectedCategoryType]]){
            NSDictionary *selectedCatEstimation = [estimationsDictionary objectForKey:[HelperClass getCatFromIntSelectionForWebService:selectedCategoryType]];
            
            if([selectedCatEstimation objectForKey:@"ride"])
                [_rideParametersDictionary setObject:[NSString stringWithFormat:@"%@", [[selectedCatEstimation objectForKey:@"ride"] objectForKey:@"costDisplay"]] forKey:@"estimatedRideCost"];
            if([selectedCatEstimation objectForKey:@"driver"])
                [_rideParametersDictionary setObject:[NSString stringWithFormat:@"%@", [[[selectedCatEstimation objectForKey:@"driver"] objectForKey:@"eta"] stringValue]] forKey:@"estimatedDriverEta"];
        }
        
        [_rideParametersDictionary setObject:[HelperClass getCatFromIntSelectionForWebService:selectedCategoryType] forKey:@"category"];
        [_rideParametersDictionary setObject:@"yes" forKey:@"comingFromHome"];
        pickupConfirm.rideParametersDictionary = _rideParametersDictionary;
    }else if([[segue identifier] isEqualToString:@"homeGoAddFavourites"]){
        AddFavouriteViewController *addFavController = [segue destinationViewController];
        addFavController.favouriteToSet = selectedFavouriteToAdd;
        addFavController.locationArray = favouriteCoordinateForFavouritesFromDropoffView;
    }
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow bringSubviewToFront:_networkErorView];
}

#pragma mark - Loading View
-(void)showLoadingView:(BOOL)show{
    if(show) {
        [loadingView removeFromSuperview];
        loadingView = nil;
        loadingView = [[LoadingCustomView alloc] initWithFrame:_mainContainerView.bounds andAnimatorY:_destinationView.frame.origin.y];
        [_mainContainerView addSubview:loadingView];
        [_mainContainerView bringSubviewToFront:loadingView];
    }else{
        [loadingView removeFromSuperview];
    }
}

@end

//
//  AddFavouriteViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "AddFavouriteViewController.h"
#import "AppDelegate.h"

@interface AddFavouriteViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@end

@implementation AddFavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _applicationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //Adjusting Pin Selection Frame
    _pinImageView.frame = CGRectMake((self.view.frame.size.width/2) - (_pinImageView.frame.size.width/2), (self.view.frame.size.height/2) - (_pinImageView.frame.size.height), _pinImageView.frame.size.width, _pinImageView.frame.size.height);

    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_headerView edgeInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f) andShadowRadius:25.0f];
    _headerView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *favBtnShadowPath = [UIHelperClass setViewShadow:_submitFavBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:25.0f];
    _submitFavBtn.layer.shadowPath = favBtnShadowPath.CGPath;
    
    [self updateMapToCam];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateMapToCam{
    GMSCameraPosition *mapViewCamera = [GMSCameraPosition cameraWithLatitude:self.applicationDelegate.currentLocation.coordinate.latitude
                                                                   longitude:self.applicationDelegate.currentLocation.coordinate.longitude
                                                                    zoom:15];
    if([_locationArray count] > 0)
        mapViewCamera = [GMSCameraPosition cameraWithLatitude:[[_locationArray objectAtIndex:0] floatValue]
                                                longitude:[[_locationArray objectAtIndex:1] floatValue]
                                                     zoom:18];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [_mapView setCamera:mapViewCamera];
    //Map Style
    GMSMapStyle *style = [RidesServiceManager setMapStyleFromFileName:@"style"];
    if(style)
        [_mapView setMapStyle:style];
}


- (IBAction)myLocBtnAction:(UIButton *)sender {
    CLLocation *location = _mapView.myLocation;
    if (location) {
        [_mapView animateToLocation:location.coordinate];
    }
}

- (IBAction)showLocationViewAction:(UIButton *)sender {
    [chooseLocationView removeFromSuperview];
    chooseLocationView = [[AddFavOnMapView alloc] initWithFrame:self.view.frame];
    chooseLocationView.delegate = self;
    [self.view addSubview:chooseLocationView];
}

#pragma mark - Location View Delegate Methods
-(void)dismissView{
    [chooseLocationView removeFromSuperview];
    chooseLocationView = nil;
}

-(void)setChosenLocation:(NSDictionary *)choosedLocation{
    if([[choosedLocation objectForKey:@"type"] isEqualToString:@"map"]){
        
    }else{
        _locationLabel.text = [choosedLocation objectForKey:@"titleString"];
        
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:CLLocationCoordinate2DMake([[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:0] doubleValue], [[[choosedLocation objectForKey:@"coordinates"] objectAtIndex:1] doubleValue]) zoom:15];
        [_mapView animateWithCameraUpdate:updatedCamera];
    }
    
}

#pragma - mark Mapview Delegate

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    _locationLabel.text = NSLocalizedString(@"loading", @"");
    [GoogleServicesManager getAddressFromCoordinates:mapView.camera.target.latitude andLong:mapView.camera.target.longitude :^(NSDictionary *response){
        _locationLabel.text = [response objectForKey:@"address"];
    }];
}

- (IBAction)addFavouriteAction:(UIButton *)sender {
    [self showLoadingView:YES];
    NSArray *placeArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", _mapView.camera.target.latitude], [NSString stringWithFormat:@"%f", _mapView.camera.target.longitude], nil];

    [self performSelectorInBackground:@selector(addFavouriteInBackground:) withObject:placeArray];
}

- (IBAction)backAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addFavouriteInBackground:(NSArray *)coordinatesArray{
    @autoreleasepool {
        NSDictionary *parameters = @{@"location" : coordinatesArray, @"type" : _favouriteToSet};
        [RidesServiceManager addFavourites:parameters :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishaddFavouriteInBackground:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishaddFavouriteInBackground:(NSDictionary *)response{
    [self showLoadingView:NO];
    if(response){
        if([response objectForKey:@"data"]){
            
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"data"] andAccessToken:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
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

@end

//
//  SplashViewController.m
//  Ego
//
//  Created by MacBookPro on 5/8/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "SplashViewController.h"
#import "Reachability.h"

@interface SplashViewController ()
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@property (nonatomic) Reachability *internetReachability;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _applicationDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"splash" withExtension:@"gif"];
//    self.gifImageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"splash viewDidAppear %@", [ServiceManager getClientDataFromUserDefaults]);
    if([HelperClass checkNetworkReachability])
        [self setStateInBG];
    else{
        if([ServiceManager getClientDataFromUserDefaults])
            [self performSegueWithIdentifier:@"splashGoHome" sender:self];
        else{
//            [self performSegueWithIdentifier:@"splashGoLogin" sender:self];
            // Get the storyboard named secondStoryBoard from the main bundle:
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"PreLogin" bundle:nil];
            
            UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
            [self presentViewController:theInitialViewController animated:YES completion:nil];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);

    if(!((long)curReach.currentReachabilityStatus == 0)){
        [self setStateInBG];
    }else{
        if([ServiceManager getClientDataFromUserDefaults])
            [self performSegueWithIdentifier:@"splashGoHome" sender:self];
        else
            [self performSegueWithIdentifier:@"splashGoLogin" sender:self];
    }
}

-(void)setStateInBG{
    [ServiceManager setClientState:^(NSDictionary *state) {
        [self finishSetState:state];
    }];
}


-(void)finishSetState:(NSDictionary *)state{
    NSLog(@"state : %@", state);
    [self performSelectorInBackground:@selector(getClientImage) withObject:nil];
    //Check if on ride
    NSString *segue = [state objectForKey:@"segue"];
    if(([segue isEqualToString:@"splashGoOnRideScreen"]) || ([segue isEqualToString:@"splashGoRating"])){
        currentRideDetails = (NSDictionary *)[state objectForKey:@"currentRide"];
        [self performSegueWithIdentifier:segue sender:self];
    }else if ([segue isEqualToString:@"splashGoLogin"]){

        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"PreLogin" bundle:nil];
        UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
        [self presentViewController:theInitialViewController animated:YES completion:nil];
        
    }else if(segue.length > 0){
        
        [self performSegueWithIdentifier:segue sender:self];
        
    }else{
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"error_title", @"") andMessage:NSLocalizedString(@"error_message", @"")] animated:YES completion:nil];
    }
}

-(void)getClientImage{
    @autoreleasepool {
        [ProfileServiceManager getClientImage:[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"photoUrl"] :^(NSData *response){
            [self performSelectorOnMainThread:@selector(finishGetClientImage:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishGetClientImage:(NSData *)response{
    [[NSUserDefaults standardUserDefaults] setObject:response forKey:@"clientImageData"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"splashGoOnRideScreen"]) {
        // Destination VC
        PickupConfirmationViewController *pickupConfirm = [segue destinationViewController];
        // Pass ride parameters to VC
        pickupConfirm.rideParametersDictionary = [currentRideDetails mutableCopy];
    }
}

@end

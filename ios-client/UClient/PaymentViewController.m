//
//  PaymentViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 8/5/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    clientData = [ServiceManager getClientDataFromUserDefaults];
    _walletCreditLabel.text = [NSString stringWithFormat:@"%i", [[clientData objectForKey:@"wallet"] intValue]];
    [self setWalletSwitch];

    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_mainView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _mainView.layer.shadowPath = shadowPath.CGPath;
}

-(void)setWalletSwitch{
    if([[clientData objectForKey:@"walletEnabled"] intValue] == 1){
        [_walletSwitch setOn:YES animated:YES];
        _walletSwitch.thumbTintColor = [UIColor whiteColor];
    }else{
        [_walletSwitch setOn:NO animated:YES];
        _walletSwitch.thumbTintColor = [UIColor lightGrayColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useWalletSwitchAction:(UISwitch *)sender {
    [self showLoadingView:YES];
    if(sender.isOn){
        [self performSelectorInBackground:@selector(toggleWallet:) withObject:@"yes"];
    }else{
        [self performSelectorInBackground:@selector(toggleWallet:) withObject:@"no"];
    }
}

-(void)toggleWallet:(NSString *)on{
    @autoreleasepool {
        if([on isEqualToString:@"yes"]){
            [ProfileServiceManager enableUsingWallet:^(NSDictionary *response){
                if([[response objectForKey:@"code"] intValue] == 200) {
                    
                    [ServiceManager getClientData:[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"] :^(NSDictionary *client) {
                        if([client objectForKey:@"data"]){
                            clientData = [client objectForKey:@"data"];

                            [ServiceManager saveLoggedInClientData:clientData andAccessToken:[[client objectForKey:@"session"] objectForKey:@"accessToken"]];
                            
                            [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:response waitUntilDone:NO];
                        }else
                            [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:response waitUntilDone:NO];
                    }];
                }else
                    [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:nil waitUntilDone:NO];
            }];
        }else{
            [ProfileServiceManager disableUsingWallet:^(NSDictionary *response){
                if([[response objectForKey:@"code"] intValue] == 200) {
                    [ServiceManager getClientData:[[ServiceManager getClientDataFromUserDefaults] objectForKey:@"_id"] :^(NSDictionary *client) {
                        if([client objectForKey:@"data"]){
                            clientData = [client objectForKey:@"data"];

                            [ServiceManager saveLoggedInClientData:clientData andAccessToken:nil];
                            
                            [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:response waitUntilDone:NO];
                        }else
                            [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:response waitUntilDone:NO];
                    }];
                }else
                    [self performSelectorOnMainThread:@selector(finishToggleWallet:) withObject:nil waitUntilDone:NO];
            }];
        }
    }
}
-(void)finishToggleWallet:(NSDictionary *)response{
    [self showLoadingView:NO];
    if(response){
        if([[response objectForKey:@"code"] intValue] == 200) {
            [self setWalletSwitch];
        }else
            [self setWalletSwitch];
    }else
        [self setWalletSwitch];
}



- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

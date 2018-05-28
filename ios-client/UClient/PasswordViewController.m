//
//  PasswordViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Here With Mobile : %@", _mobileNumber);
    [_passwordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_goBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _goBtn.layer.shadowPath = shadowPath.CGPath;
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

#pragma mark - Actions
- (IBAction)goAction:(UIButton *)sender {
    if([HelperClass validateText:_passwordTF.text]){
        [self showLoadingView:YES];
        
        /* Prepare request parameters */
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"];
        NSLog(@"device token : %@", deviceToken);
        NSDictionary *loginParams = @{@"deviceId" : (deviceToken && !([deviceToken isKindOfClass:[NSNull class]])) ? deviceToken : @"", @"role": @"client", @"device" : @"ios", @"email" : _mobileNumber, @"password" : self.passwordTF.text};
        
        [self performSelectorInBackground:@selector(loginInBackground:) withObject:loginParams];
    }else
        [self showError:_passwordSubview andMessage:NSLocalizedString(@"wrong_password", @"")];
}

- (IBAction)forgetPasswordAction:(UIButton *)sender {
    NSDictionary *params = @{@"dialCode": @"966", @"phone": _mobileNumber, @"language" : [HelperClass getDeviceLanguage]};
    [self performSelectorInBackground:@selector(requestOTP:) withObject:params];
    
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Login Request
-(void)loginInBackground:(NSDictionary *)parameters{
    @autoreleasepool {
        [ServiceManager clientLogin:parameters :^(NSDictionary *loginData) {
            [self performSelectorOnMainThread:@selector(finishLoginRequest:) withObject:loginData waitUntilDone:NO];
        }];
    }
}

-(void)finishLoginRequest:(NSDictionary *)response{
    /* Hide loading view */
    [self showLoadingView:NO];
    
    /* If login response data is valid, Call the method that save client data and access token */
    if(response && [response objectForKey:@"data"] && [response objectForKey:@"user"]){
        
//        [self performSegueWithIdentifier:@"passwordGoHome" sender:self];
        // Get the storyboard named secondStoryBoard from the main bundle:
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *homecontroller = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self presentViewController:homecontroller animated:YES completion:nil];
    }else{
        /* Login failed */
        [self showError:_passwordSubview andMessage:NSLocalizedString(@"wrong_mobile_password", @"")];
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
    if([segue.identifier isEqualToString:@"passwordGoConfirmOTP"]){
        ForgetPasswordOTPViewController *passwordController = [segue destinationViewController];
        // Pass mobile number parameters to VC
        passwordController.mobileNumber = _mobileNumber;
    }
}

#pragma mark - Request OTP before going forget password
-(void)requestOTP:(NSDictionary *)requestParameters{
    @autoreleasepool {
        [ServiceManager sendResetPasswordOTP:requestParameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishRequestOTP:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishRequestOTP:(NSDictionary *)response{
    if(response){
        if ([[response objectForKey:@"code"] intValue] == 200){
            [self performSegueWithIdentifier:@"passwordGoConfirmOTP" sender:self];
        }
    }
}

#pragma mark - Textfield Delegate
-(void)textFieldDidChange :(UITextField *)textField{
    [_passwordSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    [_errorLabel setHidden:YES];
}

#pragma mark - Error Validation
-(void)showError:(UIView *)view andMessage:(NSString *)errorMsg{
    [_errorLabel setHidden:NO];
    _errorLabel.text = errorMsg;
    
    [view setBackgroundColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0]];
}

@end

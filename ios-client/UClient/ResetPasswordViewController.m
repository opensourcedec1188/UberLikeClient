//
//  ResetPasswordViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 7/30/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_goBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _goBtn.layer.shadowPath = shadowPath.CGPath;
    
    [_passwordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_confirmPasswordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TextField Delegate
-(void)textFieldDidChange :(UITextField *)textField{
    UILabel *currentLabel;
    
    if(textField.text.length > 0){
        NSLayoutConstraint *constraint;
        if(textField == _passwordTF){
            constraint = _passwordTop;
            constraint.constant = 8;
            currentLabel = _passwordLabel;
        }else if (textField == _confirmPasswordTF){
            constraint = _confirmTop;
            constraint.constant = 11;
            currentLabel = _confirmPasswordLabel;
        }
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                             currentLabel.font = [UIFont fontWithName:FONT_ROBOTO_LIGHT size:12];
                             currentLabel.textColor = [UIColor colorWithRed:155.0/255.0f green:155.0/255.0f blue:155.0/255.0f alpha:1.0f];
                         }  completion:^(BOOL finished){}];
    }else{
        NSLayoutConstraint *constraint;
        if(textField == _passwordTF){
            constraint = _passwordTop;
            constraint.constant = 38;
            currentLabel = _passwordLabel;
        }else if (textField == _confirmPasswordTF){
            constraint = _confirmTop;
            constraint.constant = 41;
            currentLabel = _confirmPasswordLabel;
        }
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                             currentLabel.font = [UIFont fontWithName:FONT_ROBOTO_LIGHT size:16];
                             currentLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0f];
                         }  completion:^(BOOL finished){}];
    }
    
    if(textField == _passwordTF)
        [_passwSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    if(textField == _confirmPasswordTF)
        [_confirmSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    [_errorLabel setHidden:YES];
}



#pragma mark - Actions
- (IBAction)resetPasswordAction:(UIButton *)sender {
    if([HelperClass checkNetworkReachability]){
        NSString *password = _passwordTF.text;
        NSString *confirmPassword = _confirmPasswordTF.text;
        if(password && confirmPassword){
            if((password.length > 0) && (confirmPassword.length > 0)){
                if([password isEqualToString:confirmPassword]){
                    [self showLoadingView:YES];
                    NSDictionary *requestParams = @{@"password":_passwordTF.text, @"passwordConfirmation": _confirmPasswordTF.text};
                    [self performSelectorInBackground:@selector(resetPasswordInBackground:) withObject:requestParams];
                }else{
                    [self showError:_passwSubview andMessage:NSLocalizedString(@"passwords_equality_error", @"")];
                    [self showError:_confirmSubview andMessage:NSLocalizedString(@"passwords_equality_error", @"")];
                }
            }else{
                [self showError:_passwSubview andMessage:NSLocalizedString(@"missing_password", @"")];
                [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_password", @"")];
            }
        }else{
            [self showError:_passwSubview andMessage:NSLocalizedString(@"missing_password", @"")];
            [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_password", @"")];
        }
    }else{
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"network_problem_title", @"")];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Reset Password Request
-(void)resetPasswordInBackground:(NSDictionary* )parameters{
    @autoreleasepool {
        [ServiceManager resetNewPassword:parameters :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishResetPasswordInBackground:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishResetPasswordInBackground:(NSDictionary *)response{
    NSLog(@"finishResetPasswordInBackground response : %@", response);
    [self showLoadingView:NO];
    if(response){
        if([[response objectForKey:@"code"] intValue] == 200){
            UIViewController *vc = self;
            UIViewController *previousVC = self;
            while (vc.presentingViewController) {
                previousVC = vc;
                vc = vc.presentingViewController;
            }
            [previousVC dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self showError:_passwSubview andMessage:NSLocalizedString(@"missing_password", @"")];
            [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_password", @"")];
        }
    }else{
        [self showError:_passwSubview andMessage:NSLocalizedString(@"error_title", @"")];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"error_message", @"")];
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

- (IBAction)showPasswordAction:(UIButton *)sender {
    _passwordTF.secureTextEntry = !_passwordTF.secureTextEntry;
    if(!_passwordTF.secureTextEntry)
        [sender setImage:[UIImage imageNamed:@"eyeHidePassword"] forState:UIControlStateNormal];
    else
        [sender setImage:[UIImage imageNamed:@"eyeShowPassword"] forState:UIControlStateNormal];
}

- (IBAction)showConfirmPasswordAction:(UIButton *)sender {
    _confirmPasswordTF.secureTextEntry = !_confirmPasswordTF.secureTextEntry;
    if(!_confirmPasswordTF.secureTextEntry)
        [sender setImage:[UIImage imageNamed:@"eyeHidePassword"] forState:UIControlStateNormal];
    else
        [sender setImage:[UIImage imageNamed:@"eyeShowPassword"] forState:UIControlStateNormal];
}



#pragma mark - Error Validation
-(void)showError:(UIView *)view andMessage:(NSString *)errorMsg{
    [_errorLabel setHidden:NO];
    _errorLabel.text = errorMsg;
    
    [view setBackgroundColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0]];
}

@end

//
//  PasswordRegisterViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "PasswordRegisterViewController.h"

@interface PasswordRegisterViewController ()

@end

@implementation PasswordRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_passwordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_confirmPassTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_goBtn edgeInset:UIEdgeInsetsMake(-5.0f, -5.0f, -5.0f, -5.0f) andShadowRadius:5.0f];
    _goBtn.layer.shadowPath = shadowPath.CGPath;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_passwordTF performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)finishRegistrationAction:(UIButton *)sender {
    if([HelperClass checkNetworkReachability]){
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"];
        NSString *otp = [_requestParameters objectForKey:@"otp"];
        NSString *firstName = [_requestParameters objectForKey:@"firstName"];
        NSString *lastName = [_requestParameters objectForKey:@"lastName"];
        NSString *email = [_requestParameters objectForKey:@"email"];
        NSString *phone = [_requestParameters objectForKey:@"phone"];
        NSString *language = [HelperClass getDeviceLanguage];
        NSString *password = _passwordTF.text;
        NSString *passwordConfirmation = _confirmPassTF.text;
        NSDictionary *parameters =
        @{
          @"otp": (otp.length > 0) ? [_requestParameters objectForKey:@"otp"] : @"",
          @"device": @"ios",
          @"deviceId" : (deviceToken.length > 0) ? deviceToken : @"",
          @"client":
              @{
                  @"dialCode": @"966",
                  @"email": email ? email : @"",
                  @"firstName": (firstName.length > 0) ? firstName : @"",
                  @"lastName" : (lastName.length > 0) ? lastName : @"",
                  @"language": (language.length > 0) ? language : @"ar",
                  @"password" : (password.length > 0) ? password : @"",
                  @"passwordConfirmation" : (passwordConfirmation.length > 0) ? passwordConfirmation : @"",
                  @"phone" : (phone.length > 0) ? phone : @""
                  }
          };
        
        /* Validate inputs */
        NSDictionary *validation = [ClientSideValidation validateClientRegistrationData:[parameters objectForKey:@"client"]];
        if([[validation objectForKey:@"isAllValid"] isEqualToString:@"1"]){
            
            [self.delegate showRootLoadingView];
            
            /* Prepare parameters dictionary */
            [self performSelectorInBackground:@selector(RegisterFullData:) withObject:parameters];
            
        }else{
            /* One or more fields are empty */
            [self showLocalErrorsOnFields:validation];
        }
        
    }else{
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"network_problem_title", @"")];
    }
}

#pragma mark - Full Data Register Back-End

-(void)RegisterFullData:(NSDictionary *)fullData{
    @autoreleasepool {
        BOOL registered = [ServiceManager FullDataRegister:fullData :^(NSDictionary *response){
            [self performSelectorOnMainThread:@selector(finishFullDataRegister:) withObject:response waitUntilDone:NO];
        }];
        if(!registered)
            [self performSelectorOnMainThread:@selector(finishFullDataRegister:) withObject:nil waitUntilDone:NO];
    }
}
-(void)finishFullDataRegister:(NSDictionary *)clientData
{
    [self.delegate hideRootLoadingView];
    if(clientData && [clientData objectForKey:@"data"]){
        if([ServiceManager saveLoggedInClientData:[clientData objectForKey:@"data"] andAccessToken:[[clientData objectForKey:@"session"] objectForKey:@"accessToken"]]){
            //If client data saved to device, Move to the next
//            [self performSegueWithIdentifier:@"registerToMapSegue" sender:self];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *homecontroller = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self presentViewController:homecontroller animated:YES completion:nil];
            
        }else{
            //If client NOT saved to device, Error and delete client from back-end
            [self showError:_passwordSubview andMessage:@""];
            [self showError:_confirmSubview andMessage:NSLocalizedString(@"error_message", @"")];
        }
    }else{
        [self serverSideValidation:clientData];
        /* Failed */
    }
}

#pragma mark - Client-Side Validation
-(void)showLocalErrorsOnFields:(NSDictionary *)fields{
    
    if([[fields objectForKey:@"phone"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_mobile_error", @"")];
    }
    if([[fields objectForKey:@"otp"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:@"Missing OTP"];
    }
    if([[fields objectForKey:@"device"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:@"Missing device"];
    }
    if(([[fields objectForKey:@"password"] isEqualToString:@"1"]) && ([[fields objectForKey:@"passwordConfirmation"] isEqualToString:@"1"])){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_password", @"")];
    }else{
        if([[fields objectForKey:@"passwordsEquality"] isEqualToString:@"1"]){
            [self showError:_passwordSubview andMessage:@""];
            [self showError:_confirmSubview andMessage:NSLocalizedString(@"passwords_equality_error", @"")];
        }else{
            if([[fields objectForKey:@"passwordLength"] isEqualToString:@"1"]){
                [self showError:_passwordSubview andMessage:@""];
                [self showError:_confirmSubview andMessage:NSLocalizedString(@"personal_passwords_minimum_error", @"")];
            }
        }
    }
    
    if([[fields objectForKey:@"email"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"personal_invalid_email", @"")];
    }
    if([[fields objectForKey:@"firstName"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_first_name", @"")];
    }
    if([[fields objectForKey:@"lastName"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"missing_last_name", @"")];
    }
    if([[fields objectForKey:@"lastName_chars"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:@"Last name accepts english charecters only"];
    }
    if([[fields objectForKey:@"firstName_chars"] isEqualToString:@"1"]){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:@"First name accepts english charecters only"];
    }
    
}

#pragma mark - Server-Side Validation
-(void)serverSideValidation:(NSDictionary *)errorData{
    if([[errorData objectForKey:@"code"] intValue] == 400){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"error_message", @"")];
    }else if([[errorData objectForKey:@"code"] intValue] == 409){
        NSLog(@"error data : %@", errorData);
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"rider_exists", @"")];
    }else if([[errorData objectForKey:@"code"] intValue] == 401){
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"code_verify_error_title", @"")];
    }else{
        [self showError:_passwordSubview andMessage:@""];
        [self showError:_confirmSubview andMessage:NSLocalizedString(@"code_verify_error_title", @"")];
    }
}

#pragma mark - TextField Delegate
-(void)textFieldDidChange :(UITextField *)textField{
    NSLog( @"text changed: %@", textField.text);
    UILabel *currentLabel;
    
    if(textField.text.length > 0){
        NSLayoutConstraint *constraint;
        if(textField == _passwordTF){
            currentLabel = _passwordLabel;
            constraint = _passwordTop;
            constraint.constant = 26;
        }else if (textField == _confirmPassTF){
            currentLabel = _confirmPasswordLabel;
            constraint = _confirmTop;
            constraint.constant = 18;
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
            currentLabel = _passwordLabel;
            constraint = _passwordTop;
            constraint.constant = 56;
        }else if (textField == _confirmPassTF){
            constraint = _confirmTop;
            constraint.constant = 48;
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
        [_passwordSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    if(textField == _confirmPassTF)
        [_confirmSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    [_errorLabel setHidden:YES];
}

- (IBAction)showPasswordAction:(UIButton *)sender {
    _passwordTF.secureTextEntry = !_passwordTF.secureTextEntry;
    if(!_passwordTF.secureTextEntry)
        [sender setImage:[UIImage imageNamed:@"eyeHidePassword"] forState:UIControlStateNormal];
    else
        [sender setImage:[UIImage imageNamed:@"eyeShowPassword"] forState:UIControlStateNormal];
}

- (IBAction)showConfirmPasswordAction:(UIButton *)sender {
    _confirmPassTF.secureTextEntry = !_confirmPassTF.secureTextEntry;
    if(!_confirmPassTF.secureTextEntry)
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

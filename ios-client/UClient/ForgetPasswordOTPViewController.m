//
//  ForgetPasswordOTPViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 7/30/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ForgetPasswordOTPViewController.h"

@interface ForgetPasswordOTPViewController ()

@end

@implementation ForgetPasswordOTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_mobileNumber.length > 0)
        _mobileNumberLabel.text = _mobileNumber;
    
    self.firstDigitTF.customTFDelegate = self;
    self.secondDigitTF.customTFDelegate = self;
    self.thirdDigitTF.customTFDelegate = self;
    self.forthDigitTF.customTFDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /* empty textfields */
    self.firstDigitTF.text = self.secondDigitTF.text = self.thirdDigitTF.text = self.forthDigitTF.text = @"";
    /* Autofocus on First digit textfield */
    //    [self.firstDigitTF performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    [_firstDigitTF becomeFirstResponder];
    userInsertedCode = @"";
    
    [self.timer invalidate];
    [self startOTPTimer];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    [_resendOTPButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"resend_btn_initial", @"")] forState:UIControlStateNormal];
}

-(void)startOTPTimer{
    _counter = 30;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(countdownTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)countdownTimer
{
    
    if (_counter <= 0) {
        [self.timer invalidate];
        [self handleCountdownFinished];
    }else{
        _counter--;
        [_resendOTPButton setTitle:[NSString stringWithFormat:@"%lu %@" , (unsigned long)_counter, NSLocalizedString(@"resend_btn_counting", @"")] forState:UIControlStateNormal];
    }
}
-(void)handleCountdownFinished{
    [self.resendOTPButton setEnabled:YES];
    [_resendOTPButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"resend_btn_final", @"")] forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Re-send OTP Action
- (IBAction)resendOTPAction:(UIButton *)sender {
    [self.resendOTPButton setEnabled:NO];
    [_resendOTPButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"resend_btn_initial", @"")] forState:UIControlStateNormal];
    [self startOTPTimer];
    self.resendOTPButton.enabled = NO;
    if([HelperClass checkNetworkReachability]){
        if([HelperClass validateMobileNumber:_mobileNumber]){
            /* Show loading view */
            [self showLoadingView:YES];
            /* Call background method that will call service manager */
            [self performSelectorInBackground:@selector(requestOTPInBackground:) withObject:@{@"dialCode" : @"966", @"phone" : _mobileNumber, @"language": [HelperClass getDeviceLanguage]}];
        }else{
            /* Invalid data alert */
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"wrong_mobile_error", @"") andMessage:NSLocalizedString(@"wrong_mobile_error", @"")] animated:YES completion:nil];
        }
    }else{
        /* No network connection */
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"network_problem_title", @"") andMessage:NSLocalizedString(@"network_problem_message", @"")] animated:YES completion:nil];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)requestOTPInBackground:(NSDictionary *)parameters
{
    @autoreleasepool {
        [ServiceManager sendResetPasswordOTP:parameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishRequestOTP:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishRequestOTP:(NSDictionary *)response
{
    //Server side validation
    
    /* Hide loading view */
    [self showLoadingView:NO];
    NSLog(@"OTP SENT? %@", response);
    if([[response objectForKey:@"code"] intValue] == 200 )
        NSLog(@"sent again");
    else if([[response objectForKey:@"code"] intValue] == 409)
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"mobilr_exists_title", @"") andMessage:NSLocalizedString(@"mobilr_exists_message", @"")] animated:YES completion:nil];
    else
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"general_problem_title", @"") andMessage:NSLocalizedString(@"general_problem_message", @"")] animated:YES completion:nil];
}



-(void)clearTextFields{
    self.firstDigitTF.text = self.secondDigitTF.text = self.thirdDigitTF.text = self.forthDigitTF.text = @"";
}

#pragma mark - TextField Delegate methods


//Custom delete buttton
-(void)handleDelete:(UITextField *)textField{
    NSLog(@"deleeeeet");
    if (textField == self.forthDigitTF) {
        [self.thirdDigitTF becomeFirstResponder];
        self.thirdDigitTF.text = @"";
    }
    /* third digit TextField */
    if (textField == self.thirdDigitTF) {
        [self.secondDigitTF becomeFirstResponder];
        self.secondDigitTF.text = @"";
    }
    /* second digit TextField */
    if (textField == self.secondDigitTF) {
        [self.firstDigitTF becomeFirstResponder];
        self.firstDigitTF.text = @"";
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"new string : %@", string);
    /* If textfield has text */
    if(textField.text.length > 0){
        /* (user deleted existing textfield digit) -- If typed string == 0 */
        if(string.length == 0){
            /* Delete textfield text */
            [textField setText:string];
            
        }else{
            /*
             (User entered new digit -- Not allowed more that one digit)
             Don't update Textfield (length of textfield text will be more than 1)
             */
        }
        return NO; /* We already updated the text */
    }else{
        /* Text field has no text
         If typed text length > 0 */
        if(string.length == 1){
            /* Set new text */
            [textField setText:string];
            /* Check which textfield and set the next one to active
             First digit TextField */
            if (textField == self.firstDigitTF) {
                [self.secondDigitTF becomeFirstResponder];
            }
            /* Second digit TextField */
            if (textField == self.secondDigitTF) {
                [self.thirdDigitTF becomeFirstResponder];
            }
            /* Third digit TextField */
            if (textField == self.thirdDigitTF) {
                [self.forthDigitTF becomeFirstResponder];
            }
            /* Forth digit TextField */
            if (textField == self.forthDigitTF) {
                [self.forthDigitTF resignFirstResponder];
                /* concatenate 4 strings from 4 textfields */
                userInsertedCode = [NSString stringWithFormat:@"%@%@%@%@", self.firstDigitTF.text, self.secondDigitTF.text, self.thirdDigitTF.text, self.forthDigitTF.text];
                /* Check network connectevity */
                if([HelperClass checkNetworkReachability]){
                    /* Call the method that deal with back-end */
                    NSDictionary *parameters = @{@"phone" : _mobileNumber, @"dialCode" : @"966", @"otp" : userInsertedCode};
                    [self performSelectorInBackground:@selector(verifyResetPasswordOTPCode:) withObject:parameters];
                    /* Hide keyboard */
                    [self.forthDigitTF resignFirstResponder];
                    /* Show loading View */
                    [self showLoadingView:YES];
                }else{
                    /* No network connection */
                    [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"network_problem_title", @"") andMessage:NSLocalizedString(@"network_problem_message", @"")] animated:YES completion:nil];
                }
                
            }
        }
        
        return NO; // We already updated the text
    }
    return YES;
}
-(void)textDidChange:(id<UITextInput>)textInput{
    
}
-(void)selectionDidChange:(id<UITextInput>)textInput{
    
}
-(void)textWillChange:(id<UITextInput>)textInput{
    
}
-(void)selectionWillChange:(id<UITextInput>)textInput{
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Confirm OTP Code Back-End
-(void)verifyResetPasswordOTPCode:(NSDictionary *)parameters{
    @autoreleasepool {
        [ServiceManager confirmResetPasswordOTP:parameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishVerifyOTPCode:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishVerifyOTPCode:(NSDictionary *)response
{
    [self showLoadingView:NO];
    if([[response objectForKey:@"code"] intValue] == 200 ){
        [ServiceManager savePhoneSession:[[response objectForKey:@"phoneSession"] objectForKey:@"accessToken"]];
        [self moveToConfirmPassword];
    }else
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"code_verify_error_title", @"") andMessage:NSLocalizedString(@"code_verify_error_message", @"")] animated:YES completion:nil];
    [self clearTextFields];
}

- (void)moveToConfirmPassword {
    //Go to new screen
    [self performSegueWithIdentifier:@"GoChangePasword" sender:self];
}

#pragma mark - Hide Keyboard when click anywhere
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
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

//
//  ConfirmMobileViewController.m
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ConfirmMobileViewController.h"

@interface ConfirmMobileViewController ()

@end

@implementation ConfirmMobileViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_requestParameters){
        if([_requestParameters objectForKey:@"phone"])
            _mobileNumberLabel.text = [_requestParameters objectForKey:@"phone"];
    }
    
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
        [_resendOTPButton setTitle:[NSString stringWithFormat:@"%@ %lu %@", NSLocalizedString(@"sent", @"") , (unsigned long)_counter, NSLocalizedString(@"resend_btn_counting", @"")] forState:UIControlStateNormal];
    }
}
-(void)handleCountdownFinished{
    [_resendOTPButton setEnabled:YES];
    [_resendOTPButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"resend_btn_final", @"")] forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Re-send OTP Action
- (IBAction)resendOTPAction:(UIButton *)sender {
    [_resendOTPButton setEnabled:NO];
    [_resendOTPButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"resend_btn_initial", @"")] forState:UIControlStateNormal];
    [self startOTPTimer];
    self.resendOTPButton.enabled = NO;
    if([HelperClass checkNetworkReachability]){
        if([HelperClass validateMobileNumber:[_requestParameters objectForKey:@"phone"]]){
            /* Show loading view */
            [self.delegate showRootLoadingView];
            /* Call background method that will call service manager */
            [self performSelectorInBackground:@selector(requestOTPInBackground:) withObject:_requestParameters];
        }else{
            /* Invalid data alert */
            [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"wrong_mobile_error", @"") andMessage:NSLocalizedString(@"wrong_mobile_error", @"")] animated:YES completion:nil];
        }
    }else{
        /* No network connection */
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"network_problem_title", @"") andMessage:NSLocalizedString(@"network_problem_message", @"")] animated:YES completion:nil];
    }
}

-(void)requestOTPInBackground:(NSDictionary *)parameters
{
    @autoreleasepool {
        [ServiceManager requestOTPCode:parameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishRequestOTPInBackground:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishRequestOTPInBackground:(NSDictionary *)response
{
    //Server side validation
    
    /* Hide loading view */
    [self.delegate hideRootLoadingView];
    NSLog(@"OTP SENT? %@", response);
    if([[response objectForKey:@"code"] intValue] == 200 )
        NSLog(@"sent again");
    else if([[response objectForKey:@"code"] intValue] == 409)
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"mobilr_exists_title", @"") andMessage:NSLocalizedString(@"mobilr_exists_message", @"")] animated:YES completion:nil];
    else
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"general_problem_title", @"") andMessage:NSLocalizedString(@"general_problem_message", @"")] animated:YES completion:nil];
}

#pragma mark - Confirm OTP Code Back-End

-(void)verifyOTPCode:(NSDictionary *)parameters{
    @autoreleasepool {
        [ServiceManager confirmOTPCode:parameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishVerifyOTPCode:) withObject:response waitUntilDone:NO];
        }];
    }
}
-(void)finishVerifyOTPCode:(NSDictionary *)response
{
    [self.delegate hideRootLoadingView];
    NSLog(@"done confirming OTP code with response %@", response);
    if([[response objectForKey:@"code"] intValue] == 200 ){
        [ServiceManager savePhoneSession:[[response objectForKey:@"phoneSession"] objectForKey:@"accessToken"]];
        [self goToRegister];
    }else
        [self presentViewController:[HelperClass showAlert:NSLocalizedString(@"code_verify_error_title", @"") andMessage:NSLocalizedString(@"code_verify_error_message", @"")] animated:YES completion:nil];
    [self clearTextFields];
}

- (void)goToRegister {
    [_requestParameters setObject:userInsertedCode forKey:@"otp"];
    [self.delegate moveToRegisterController:_requestParameters];
}

-(void)clearTextFields{
    self.firstDigitTF.text = self.secondDigitTF.text = self.thirdDigitTF.text = self.forthDigitTF.text = @"";
}

#pragma mark - TextField Delegate methods


//Custom delete buttton
-(void)handleDelete:(UITextField *)textField{
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
            /* third digit TextField */
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
                    NSDictionary *parameters = @{@"phone" : [_requestParameters objectForKey:@"phone"], @"dialCode" : [_requestParameters objectForKey:@"dialCode"], @"otp" : userInsertedCode};
                    [self performSelectorInBackground:@selector(verifyOTPCode:) withObject:parameters];
                    /* Hide keyboard */
                    [self.forthDigitTF resignFirstResponder];
                    /* Show loading View */
                    [self.delegate showRootLoadingView];
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


#pragma mark - Hide Keyboard when click anywhere
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
}

@end

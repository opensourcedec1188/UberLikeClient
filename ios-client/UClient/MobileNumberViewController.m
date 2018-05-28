//
//  MobileNumberViewController.m
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "MobileNumberViewController.h"

@interface MobileNumberViewController ()

@end

@implementation MobileNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_goBtn edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _goBtn.layer.shadowPath = shadowPath.CGPath;
    
    [_mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Login Action
- (IBAction)goAction:(UIButton *)sender {
    if([HelperClass checkNetworkReachability]){
        if(_mobileTextField.text.length > 0){
            //Detect language
            NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
            NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
            [tagger setString:_mobileTextField.text];
            NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
            
            int phoneNumb = 0;
            
            mobileNumberEnglish = [NSString stringWithFormat:@"%@", _mobileTextField.text];
            if([language isEqualToString:@"ar"]){
                phoneNumb = [HelperClass convertArabicNumber:_mobileTextField.text];
                mobileNumberEnglish = [NSString stringWithFormat:@"%d", phoneNumb];
            }
            
            if([HelperClass validateMobileNumber:mobileNumberEnglish]){
                /* Show loading view */
                [self showLoadingView:YES];
                /* Call background method that will call service manager */
                parametersForRegistration = @{@"dialCode": @"966", @"phone": mobileNumberEnglish, @"language" : [HelperClass getDeviceLanguage]};
                [self performSelectorInBackground:@selector(checkNumberInBackGround:) withObject:parametersForRegistration];
            }else{
                //Invalid data alert
                [self showError:_mobileSubView andMessage:NSLocalizedString(@"wrong_mobile_error", @"")];
            }
        }else{
            [self showError:_mobileSubView andMessage:NSLocalizedString(@"missing_mobile_error", @"")];
        }
    }else{
        [self showError:_mobileSubView andMessage:NSLocalizedString(@"network_problem_title", @"")];
    }
}

-(void)checkNumberInBackGround:(NSDictionary *)parameters{
    @autoreleasepool {
        [ServiceManager requestOTPCode:parameters :^(NSDictionary *response) {
            [self performSelectorOnMainThread:@selector(finishCheckNumberInBackGround:) withObject:response waitUntilDone:NO];
        }];
    }
}

-(void)finishCheckNumberInBackGround:(NSDictionary *)response{
    [self showLoadingView:NO];
    if(response){
        if([[response objectForKey:@"code"] intValue] == 409){
            //User Registered, Go to password
            [self performSegueWithIdentifier:@"MobileGoPassword" sender:self];
        }else if ([[response objectForKey:@"code"] intValue] == 200){
            //Not Registered, Go Registration
            [self performSegueWithIdentifier:@"MobileGoRegister" sender:self];
        }else{
            [self showError:_mobileSubView andMessage:NSLocalizedString(@"wrong_mobile_error", @"")];
        }
    }else
        [self showError:_mobileSubView andMessage:NSLocalizedString(@"wrong_mobile_error", @"")];
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
    if([segue.identifier isEqualToString:@"MobileGoPassword"]){
        PasswordViewController *passwordController = [segue destinationViewController];
        // Pass mobile number parameters to VC
        passwordController.mobileNumber = mobileNumberEnglish;
    }else if([segue.identifier isEqualToString:@"MobileGoRegister"]){
        RegisterRootViewController *rootController = [segue destinationViewController];
        // Pass mobile number parameters to VC
        rootController.requestParameters = parametersForRegistration;
    }
}

#pragma mark - Hide Keyboard when click anywhere
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
}

#pragma mark - Textfield Delegate
-(void)textFieldDidChange :(UITextField *)textField{
    [_mobileSubView setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    [_errorLabel setHidden:YES];
}

#pragma mark - Error Validation
-(void)showError:(UIView *)view andMessage:(NSString *)errorMsg{
    [_errorLabel setHidden:NO];
    _errorLabel.text = errorMsg;
    
    [view setBackgroundColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0]];
}


@end

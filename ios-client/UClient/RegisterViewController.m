//
//  RegisterViewController.m
//  Ego
//
//  Created by MacBookPro on 2/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [_fNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_sNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_emailTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_goBtn edgeInset:UIEdgeInsetsMake(-5.0f, -5.0f, -5.0f, -5.0f) andShadowRadius:5.0f];
    _goBtn.layer.shadowPath = shadowPath.CGPath;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /* Autofocus on First Name textfield */
    [_fNameTF performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)continueRegistration:(UIButton *)sender {
    if([HelperClass checkNetworkReachability]){
        if([HelperClass validateText:_fNameTF.text]){
            if([HelperClass validateText:_sNameTF.text]){
                if([HelperClass validateEmailAddress:_emailTF.text]){
                    [_requestParameters setObject:_fNameTF.text forKey:@"firstName"];
                    [_requestParameters setObject:_sNameTF.text forKey:@"lastName"];
                    [_requestParameters setObject:_emailTF.text forKey:@"email"];
                    [self.delegate moveToPasswordRegistration:_requestParameters];
                }else{
                    [self showError:_emailSubview andMessage:NSLocalizedString(@"missing_email", @"")];
                }
            }else{
                [self showError:_sNameSubview andMessage:NSLocalizedString(@"missing_last_name", @"")];
            }
        }else{
            [self showError:_fNameSubview andMessage:NSLocalizedString(@"missing_first_name", @"")];
        }
    }
}



#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    if((textField == self.fNameTF) || (textField == self.sNameTF)){
        
        if(textField.text.length > 24 && range.length == 0){
            return NO;
        }else
            return YES;
    }

    if(textField == self.emailTF){
        if(textField.text.length > 254 && range.length == 0){
            return NO;
        }else
            return YES;
    }
    return YES;
    
}

-(void)textFieldDidChange :(UITextField *)textField{
    UILabel *currentLabel;
    
    if(textField.text.length > 0){
        NSLayoutConstraint *constraint;
        if(textField == _fNameTF){
            constraint = _firstNameTop;
            constraint.constant = 11;
            currentLabel = _firstNameLabel;
        }else if (textField == _sNameTF){
            constraint = _snameTop;
            constraint.constant = 11;
            currentLabel = _lastNameLabel;
        }else if (textField == _emailTF){
            constraint = _emailTop;
            constraint.constant = 5;
            currentLabel = _emailLabel;
        }
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                             currentLabel.font = [UIFont fontWithName:FONT_ROBOTO_LIGHT size:12];
                             currentLabel.textColor = [UIColor colorWithRed:155.0/255.0f green:155.0/255.0f blue:155.0/255.0f alpha:1.0f];
                         }  completion:^(BOOL finished){}];
    }else{
        NSLayoutConstraint *constraint;
        if(textField == _fNameTF){
            constraint = _firstNameTop;
            constraint.constant = 41;
            currentLabel = _firstNameLabel;
        }else if (textField == _sNameTF){
            constraint = _snameTop;
            constraint.constant = 41;
            currentLabel = _lastNameLabel;
        }else if (textField == _emailTF){
            constraint = _emailTop;
            constraint.constant = 35;
            currentLabel = _emailLabel;
        }
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.view layoutIfNeeded];
                             currentLabel.font = [UIFont fontWithName:FONT_ROBOTO_LIGHT size:16];
                             currentLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0f];
                         }  completion:^(BOOL finished){}];
    }
    
    if(textField == _fNameTF)
        [_fNameSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    if(textField == _sNameTF)
        [_sNameSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    if(textField == _emailTF)
        [_emailSubview setBackgroundColor:[UIColor colorWithRed:34.0/255.0f green:50.0/255.0f blue:73.0/255.0f alpha:1.0]];
    [_errorLabel setHidden:YES];
}

#pragma mark - Error Validation
-(void)showError:(UIView *)view andMessage:(NSString *)errorMsg{
    [_errorLabel setHidden:NO];
    _errorLabel.text = errorMsg;
    
    [view setBackgroundColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0]];
}
@end

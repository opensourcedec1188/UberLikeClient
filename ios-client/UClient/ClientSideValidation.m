//
//  ClientSideValidation.m
//  Ego
//
//  Created by MacBookPro on 4/8/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ClientSideValidation.h"

@implementation ClientSideValidation

+(NSDictionary *)validateClientRegistrationData:(NSDictionary *)dataToValidate{
    BOOL valid = YES;
    NSMutableDictionary *validationDetails = [[NSMutableDictionary alloc] init];
    if([HelperClass validateEmailAddress:[dataToValidate objectForKey:@"email"]]){
        [validationDetails setObject:@"0" forKey:@"email"];
    }else{
        [validationDetails setObject:@"1" forKey:@"email"];
        valid = NO;
    }
    
    if([HelperClass validateText:[dataToValidate objectForKey:@"firstName"]]){
        [validationDetails setObject:@"0" forKey:@"firstName"];
    }else{
        [validationDetails setObject:@"1" forKey:@"firstName"];
        valid = NO;
    }
    
    if([HelperClass validateFLNames:[dataToValidate objectForKey:@"firstName"]]){
        [validationDetails setObject:@"0" forKey:@"firstName_chars"];
    }else{
        [validationDetails setObject:@"1" forKey:@"firstName_chars"];
        valid = NO;
    }
    
    if([HelperClass validateText:[dataToValidate objectForKey:@"lastName"]]){
        [validationDetails setObject:@"0" forKey:@"lastName"];
    }else{
        [validationDetails setObject:@"1" forKey:@"lastName"];
        valid = NO;
    }
    
    if([HelperClass validateFLNames:[dataToValidate objectForKey:@"lastName"]]){
        [validationDetails setObject:@"0" forKey:@"lastName_chars"];
    }else{
        [validationDetails setObject:@"1" forKey:@"lastName_chars"];
        valid = NO;
    }
    if([HelperClass validateText:[dataToValidate objectForKey:@"password"]]){
        [validationDetails setObject:@"0" forKey:@"password"];
    }else{
        [validationDetails setObject:@"1" forKey:@"password"];
        valid = NO;
    }
    if([HelperClass validateText:[dataToValidate objectForKey:@"passwordConfirmation"]]){
        [validationDetails setObject:@"0" forKey:@"passwordConfirmation"];
    }else{
        [validationDetails setObject:@"1" forKey:@"passwordConfirmation"];
        valid = NO;
    }

    NSString *firstPass = [dataToValidate objectForKey:@"password"];
    NSString *secondPass = [dataToValidate objectForKey:@"passwordConfirmation"];
    
    if([firstPass isEqualToString:secondPass]){
        [validationDetails setObject:@"0" forKey:@"passwordsEquality"];
    }else{
        [validationDetails setObject:@"1" forKey:@"passwordsEquality"];
        valid = NO;
    }
    
    if(( firstPass.length >= 6) && ( firstPass.length <= 72 ) && ( secondPass.length >= 6) && ( secondPass.length <= 72 )){
        [validationDetails setObject:@"0" forKey:@"passwordLength"];
    }else{
        [validationDetails setObject:@"1" forKey:@"passwordLength"];
    }
    
    [validationDetails setObject:valid ? @"1" : @"0" forKey:@"isAllValid"];
    
    return validationDetails;
}

@end

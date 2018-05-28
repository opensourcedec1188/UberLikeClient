//
//  ClientSideValidation.h
//  Ego
//
//  Created by MacBookPro on 4/8/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HelperClass.h"

@interface ClientSideValidation : NSObject

+(NSDictionary *)validateClientRegistrationData:(NSDictionary *)dataToValidate;



@end

//
//  CustomTextField.m
//  Ego
//
//  Created by MacBookPro on 4/15/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (void)deleteBackward
{
    [self.customTFDelegate handleDelete:self];
    [super deleteBackward];
}

@end

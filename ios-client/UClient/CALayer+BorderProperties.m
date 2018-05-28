//
//  CALayer+BorderProperties.m
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "CALayer+BorderProperties.h"

@implementation CALayer (BorderProperties)


- (void)setBorderUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

@end

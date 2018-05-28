//
//  UIHelperClass.m
//  EgoDriver
//
//  Created by Mahmoud Amer on 9/14/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "UIHelperClass.h"

@implementation UIHelperClass

#pragma mark - shadow function
+(UIBezierPath *)setViewShadow:(UIView *)viewToDraw edgeInset:(UIEdgeInsets)insets andShadowRadius:(float)shadowRadius{
    if(viewToDraw != nil){
        viewToDraw.layer.masksToBounds = NO;
        viewToDraw.layer.shadowRadius  = shadowRadius;
        viewToDraw.layer.shadowColor = [[UIColor blackColor] CGColor];
        viewToDraw.layer.shadowOffset  = CGSizeZero;
        viewToDraw.layer.shadowOpacity = 0.3f;
        UIEdgeInsets shadowInsets = insets;
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(viewToDraw.bounds, shadowInsets)];
        return shadowPath;
    }else{
        viewToDraw.layer.shadowPath = nil;
        return nil;
    }
    
}

@end

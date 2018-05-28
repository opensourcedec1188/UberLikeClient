//
//  UIHelperClass.h
//  EgoDriver
//
//  Created by Mahmoud Amer on 9/14/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIHelperClass : NSObject

+(UIBezierPath *)setViewShadow:(UIView *)viewToDraw edgeInset:(UIEdgeInsets)insets andShadowRadius:(float)shadowRadius;


@end

//
//  CategoriesScrollView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/30/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "CategoriesScrollView.h"

@implementation CategoriesScrollView

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

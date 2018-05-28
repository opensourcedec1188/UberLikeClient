//
//  LoadingCustomView.m
//  Ego
//
//  Created by Mahmoud Amer on 8/29/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "LoadingCustomView.h"

@implementation LoadingCustomView {
    NSArray *_colorsFirst;
    NSArray *_colorsSecond;
    NSArray *_currentColor;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInitWithAnimatorY:0];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame andAnimatorY:(float)animatorY{
    self = [super initWithFrame:frame];
    
    if(self){
        [self customInitWithAnimatorY:animatorY];
    }
    
    return self;
}

-(void)customInitWithAnimatorY:(float)animatorY{
    [[NSBundle mainBundle] loadNibNamed:@"LoadingCustomView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    _progressView = [[M13ProgressViewStripedBar alloc] initWithFrame:CGRectMake(0.0, animatorY - 4, self.frame.size.width, 4)];
    
    // Configure the progress view here.
    [_progressView setTintColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0f]];
    _progressView.indeterminate = YES;
    _progressView.animateStripes = YES;
    _progressView.showStripes = YES;
    _progressView.layer.borderWidth = 0;
    // Add it to the view.
    [self addSubview: _progressView];
    
    // Update the progress as needed
    [_progressView setProgress: 1.0 animated: YES];
}



@end

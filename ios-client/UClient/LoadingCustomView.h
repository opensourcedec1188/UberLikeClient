//
//  LoadingCustomView.h
//  Ego
//
//  Created by Mahmoud Amer on 8/29/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M13ProgressView.h"
#import "M13ProgressViewStripedBar.h"
#import "M13ProgressViewBar.h"

@interface LoadingCustomView : UIView {
    
}

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (strong, nonatomic) M13ProgressViewStripedBar *progressView;

-(instancetype)initWithFrame:(CGRect)frame andAnimatorY:(float)animatorY;
@end

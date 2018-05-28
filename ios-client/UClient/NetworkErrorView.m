//
//  NetworkErrorView.m
//  Ego
//
//  Created by Mahmoud Amer on 8/13/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "NetworkErrorView.h"

@implementation NetworkErrorView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        [self customInit];
    }
    
    return self;
}

-(void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"NetworkErrorView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
}

- (IBAction)dismissBtnAction:(UIButton *)sender {
    [[self delegate] hideNetworkErrorView];
}
@end

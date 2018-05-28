//
//  PaymentSelectView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/25/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "PaymentSelectView.h"

@implementation PaymentSelectView

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
    [[NSBundle mainBundle] loadNibNamed:@"PaymentSelectView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
}

- (IBAction)hideMeAction:(UIButton *)sender {
    [[self delegate] dismissPaymentView];
}
@end

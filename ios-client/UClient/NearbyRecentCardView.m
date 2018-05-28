//
//  NearbyRecentCardView.m
//  Ego
//
//  Created by Mahmoud Amer on 8/2/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "NearbyRecentCardView.h"

@implementation NearbyRecentCardView

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
    [[NSBundle mainBundle] loadNibNamed:@"NearbyRecentCardView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
}

- (IBAction)setSelectedAddress:(UIButton *)sender{
    if([_type isEqualToString:@"nearby"])
        [self.delegate setNearByAsDropoff:[[NSNumber numberWithInteger:sender.tag] intValue]];
    else if ([_type isEqualToString:@"favourite"])
        [self.delegate setFavouriteAsDropOff:[[NSNumber numberWithInteger:sender.tag] intValue]];
    else if ([_type isEqualToString:@"recent"])
        [self.delegate setRecentAsDropoff:[[NSNumber numberWithInteger:sender.tag] intValue]];
}

- (IBAction)addButtonAction:(UIButton *)sender {
    NSLog(@"should go favourite controller with key : %i", [[NSNumber numberWithInteger:sender.tag] intValue]);
    [[self delegate] goToAddFavouritedWithKey:[[NSNumber numberWithInteger:sender.tag] intValue]];
}


-(void)setEmpty{
    [_filledContentView setHidden:YES];
    [_emptyContentView setHidden:NO];
    
    CAShapeLayer *yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor colorWithRed:151/255 green:151/255 blue:151/255 alpha:0.4f].CGColor;
    yourViewBorder.lineDashPattern = @[@4, @3];
    
    CGRect shapeRect = CGRectMake(_dashedView.frame.origin.x, _dashedView.frame.origin.y, _dashedView.frame.size.width, _dashedView.frame.size.height);
    [yourViewBorder setBounds:shapeRect];
    
    [yourViewBorder setPosition:CGPointMake( _dashedView.frame.size.width/2,_dashedView.frame.size.height/2)];
    
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:shapeRect].CGPath;
    yourViewBorder.fillColor = [UIColor clearColor].CGColor;
    [_dashedView.layer addSublayer:yourViewBorder];
    [_dashedView bringSubviewToFront:_addFavBtn];
}

@end

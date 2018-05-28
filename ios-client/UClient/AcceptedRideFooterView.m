//
//  AcceptedRideFooterView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "AcceptedRideFooterView.h"

@implementation AcceptedRideFooterView

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
    [[NSBundle mainBundle] loadNibNamed:@"AcceptedRideFooterView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];

    self.CONTENTVIEW.frame = self.bounds;
    
    acceptedFooterPanGesture = [[UIPanGestureRecognizer alloc]  initWithTarget:self action:@selector(panAcceptedFooterView:)];
    [self removeGestureRecognizer:acceptedFooterPanGesture];
    [self addGestureRecognizer:acceptedFooterPanGesture];
    
    initialY= self.frame.origin.y;
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_windowView edgeInset:UIEdgeInsetsMake(-1.5f, -1.5f, -1.5f, -1.5f) andShadowRadius:5.0f];
    _windowView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *IMGShadowPath = [UIHelperClass setViewShadow:_acceptedDriverImageView edgeInset:UIEdgeInsetsMake(-1.5f, -1.5f, -1.5f, -1.5f) andShadowRadius:5.0f];
    _acceptedDriverImageView.layer.shadowPath = IMGShadowPath.CGPath;
}

-(void)addBGView{
    if(!_initialCancelConfirmBGView.superview){
        [_initialCancelConfirmBGView removeFromSuperview];
        _initialCancelConfirmBGView = [[UIView alloc] initWithFrame:self.superview.bounds];
        _initialCancelConfirmBGView.backgroundColor = [UIColor colorWithRed:0/255 green:0/200 blue:0/255 alpha:0.9];
        [self.superview insertSubview:_initialCancelConfirmBGView belowSubview:self];
        [_initialCancelConfirmBGView setHidden:NO];
    }
}

#pragma mark - Accepted Cancel Gesture
-(void)panAcceptedFooterView:(UIPanGestureRecognizer *)gesture{
    
    CGPoint translatedPoint = [gesture translationInView:gesture.view.superview];
    if(gesture.state == UIGestureRecognizerStateBegan){
        initialYAfterPan = self.frame.origin.y;
    }
    
    if(((self.center.y + translatedPoint.y) - (self.frame.size.height/2)) < initialY){
        if((self.frame.origin.y >= (self.superview.frame.size.height - self.frame.size.height))){
            self.center = CGPointMake(self.center.x, self.center.y + translatedPoint.y);
            
            if(self.frame.origin.y < initialY){
                [self addBGView];
                [_initialCancelConfirmBGView setHidden:NO];
                [_initialCancelConfirmBGView setAlpha:((self.superview.frame.size.height - self.frame.size.height)/(self.frame.origin.y))];
            }else
                [_initialCancelConfirmBGView setHidden:YES];
            
        }else{
            [acceptedFooterPanGesture setEnabled:NO];
            [self setFinalAcceptedFooterFrame];
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            finalYAfterPan = self.frame.origin.y;
            [self setFinalAcceptedFooterFrame];
            [acceptedFooterPanGesture setEnabled:YES];
        }
    }
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

#pragma mark - Footer Final frame after pan gesture
-(void)setFinalAcceptedFooterFrame{
    [acceptedFooterPanGesture setEnabled:YES];
    if(finalYAfterPan > initialYAfterPan){
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_initialCancelConfirmBGView setAlpha:0.0f];
                             self.frame = CGRectMake(self.frame.origin.x, initialY, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                             [_acceptedCencelConfirmationView setHidden:YES];
                             [_initialCancelConfirmBGView setHidden:YES];
                         }];
    }else{
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [_acceptedCencelConfirmationView setHidden:YES];
                             [_initialCancelConfirmBGView setAlpha:1.0f];
                         }];
    }
}

-(void)convertAcceptedViewToConfirmationMode:(BOOL)convert{
    if(convert){
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_acceptedCencelConfirmationView setHidden:NO];
                             [self bringSubviewToFront:_acceptedCencelConfirmationView];
                         }
                         completion:^(BOOL finished){}];
    }else{
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_acceptedCencelConfirmationView setHidden:YES];
                             [self bringSubviewToFront:_windowView];
                         }
                         completion:^(BOOL finished){

                         }];
    }
}

- (IBAction)acceptedCancelAction:(UIButton *)sender {
    [self convertAcceptedViewToConfirmationMode:YES];
}

- (IBAction)confirmAcceptedCancelButtonAction:(UIButton *)sender {
    [self.delegate cancelAction];
}

- (IBAction)notConfirmAcceptedCancelBtnAction:(UIButton *)sender {
    [self convertAcceptedViewToConfirmationMode:NO];
}

- (IBAction)acceptedRideCallBtnAction:(UIButton *)sender {
    
}

- (IBAction)callBtnAction:(UIButton *)sender {
    [[self delegate] callDriverPhone];
}

@end

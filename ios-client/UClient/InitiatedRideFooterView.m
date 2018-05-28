//
//  InitiatedRideFooterView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "InitiatedRideFooterView.h"

@implementation InitiatedRideFooterView

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
    [[NSBundle mainBundle] loadNibNamed:@"InitiatedRideFooterView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_containerView edgeInset:UIEdgeInsetsMake(-5.0f, -5.0f, -5.0f, -5.0f) andShadowRadius:5.0f];
    _containerView.layer.shadowPath = shadowPath.CGPath;
    
    initialY= self.frame.origin.y;
    
}

#pragma mark - Initiation Cancel Gesture
-(void)panInitialFooterView:(UIPanGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        initialYAfterPan = self.frame.origin.y;
    }
    CGPoint translatedPoint = [gesture translationInView:gesture.view.superview];
    
    if((self.frame.origin.y >= (self.superview.frame.size.height - self.frame.size.height))){
        self.center = CGPointMake(self.center.x, self.center.y + translatedPoint.y);
        
    }else{
        [initiatedFooterPanGesture setEnabled:NO];
        [self setFinalInitialFooterFrame];
    }
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setFinalInitialFooterFrame];
        [initiatedFooterPanGesture setEnabled:YES];
    }
}

#pragma mark - Footer Final frame after pan gesture
-(void)setFinalInitialFooterFrame{
    [initiatedFooterPanGesture setEnabled:YES];
    if(self.frame.origin.y > initialYAfterPan){//(self.superview.frame.size.height - (self.frame.size.height * 2 /3) )){
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, initialY, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [_initiatedCancelConfirmationView setHidden:YES];
                         }];
    }else{
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - (_containerView.frame.origin.y + _initialCancelBtn.frame.origin.y + _initialCancelBtn.frame.size.height + 15), self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [_initiatedCancelConfirmationView setHidden:YES];
                         }];
    }
}

-(void)convertInitialViewToConfirmationMode:(BOOL)convert{
    if(convert){
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_initiatedCancelConfirmationView setHidden:NO];
//                             self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){}];
    }else{
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{

                             [_initiatedCancelConfirmationView setHidden:YES];
//                             self.frame = CGRectMake(self.frame.origin.x, initialY, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}
- (IBAction)initiatedCancelAction:(UIButton *)sender {
    [self convertInitialViewToConfirmationMode:YES];
}

- (IBAction)confirminitiatedCancelButtonAction:(UIButton *)sender {
    [self.delegate cancelAction];
}

- (IBAction)notConfirminitiatedCancelBtnAction:(UIButton *)sender {
    [self convertInitialViewToConfirmationMode:NO];
}


#pragma mark - Loading View
-(void)showCustomLoadingView:(BOOL)show{
    if(show) {
        // Configure the progress view here.
        _progressView = [[M13ProgressViewStripedBar alloc] initWithFrame:CGRectMake(0.0, _containerView.frame.origin.y - 4 , self.frame.size.width, 4)];
        [_progressView setTintColor:[UIColor colorWithRed:247.0/255.0f green:17.0/255.0f blue:94.0/255.0f alpha:1.0f]];
        _progressView.indeterminate = YES;
        _progressView.animateStripes = YES;
        _progressView.showStripes = YES;
        _progressView.layer.borderWidth = 0;
        // Add it to the view.
        [self addSubview: _progressView];
        
        // Update the progress as needed
        [_progressView setProgress: 1.0 animated: YES];
    }else{
        [_progressView removeFromSuperview];
        _progressView = nil;
    }
}

@end

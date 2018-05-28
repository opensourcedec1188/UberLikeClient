//
//  OnRideFooterView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "OnRideFooterView.h"

@implementation OnRideFooterView


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)reasonsArray{
    self = [super initWithFrame:frame];
    cancelationReasonsArray = reasonsArray;
    if(self){
        [self customInit];
    }
    
    return self;
}

- (IBAction)callBtnAction:(UIButton *)sender {
    [[self delegate] callDriverPhone];
}

-(void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"OnRideFooterView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    UINib *cellNib = [UINib nibWithNibName:@"CancelationReasonsTableViewCell" bundle:nil];
    [_reasonsTableView registerNib:cellNib forCellReuseIdentifier:@"defaultCell"];
    [_reasonsTableView reloadData];
    
    initialY = self.frame.origin.y;
    
    onRideFooterPanGesture = [[UIPanGestureRecognizer alloc]  initWithTarget:self action:@selector(panOnRideFooterView:)];
    [self removeGestureRecognizer:onRideFooterPanGesture];
    [self addGestureRecognizer:onRideFooterPanGesture];
    
    UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_mainView edgeInset:UIEdgeInsetsMake(-1.5f, -1.5f, -1.5f, -1.5f) andShadowRadius:5.0f];
    _mainView.layer.shadowPath = shadowPath.CGPath;
}

-(void)addBGView{
    if(!_onRideCancelConfirmBGView.superview){
        [_onRideCancelConfirmBGView removeFromSuperview];
        _onRideCancelConfirmBGView = [[UIView alloc] initWithFrame:self.superview.bounds];
        _onRideCancelConfirmBGView.backgroundColor = [UIColor colorWithRed:0/255 green:0/200 blue:0/255 alpha:0.9];
        [self.superview insertSubview:_onRideCancelConfirmBGView belowSubview:self];
        [_onRideCancelConfirmBGView setHidden:NO];
    }
}

#pragma mark - Initiation Cancel Gesture
-(void)panOnRideFooterView:(UIPanGestureRecognizer *)gesture{
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        initialYAfterPan = self.frame.origin.y;
    }
    
    CGPoint translatedPoint = [gesture translationInView:gesture.view.superview];
    
    if(((self.center.y + translatedPoint.y) - (self.frame.size.height/2)) < initialY){
        
        if((self.frame.origin.y >= (self.superview.frame.size.height - self.frame.size.height))){
            self.center = CGPointMake(self.center.x, self.center.y + translatedPoint.y);
            if(self.frame.origin.y < initialY){
                [self addBGView];
                [_onRideCancelConfirmBGView setHidden:NO];
                [_onRideCancelConfirmBGView setAlpha:((self.superview.frame.size.height - self.frame.size.height)/(self.frame.origin.y))];
            }else
                [_onRideCancelConfirmBGView setHidden:YES];
            
        }else{
            [onRideFooterPanGesture setEnabled:NO];
            [self setFinalInitialFooterFrame];
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            [self setFinalInitialFooterFrame];
            [onRideFooterPanGesture setEnabled:YES];
        }
    }
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

#pragma mark - Footer Final frame after pan gesture
-(void)setFinalInitialFooterFrame{
    [onRideFooterPanGesture setEnabled:YES];
    if(self.frame.origin.y > initialYAfterPan){//  (self.superview.frame.size.height - (self.frame.size.height /2) )){
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_onRideCancelConfirmBGView setAlpha:0.0f];
                             self.frame = CGRectMake(self.frame.origin.x, initialY, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [_onRideCancelConfirmBGView setHidden:YES];
                         }];
    }else{
        [_onRideCancelConfirmBGView setHidden:NO];
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_onRideCancelConfirmBGView setAlpha:1.0f];
                             self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cancelationReasonsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"defaultcell";
    CancelationReasonsTableViewCell *cell = (CancelationReasonsTableViewCell *)[_reasonsTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CancelationReasonsTableViewCell" owner:self options:nil];
        cell = defaultCell;
    }
    
    [cell.rightCheckMarkImg setHidden:YES];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.reasonLabel.textColor = [UIColor whiteColor];
    cell.reasonLabel.text = [[cancelationReasonsArray objectAtIndex:indexPath.row] objectForKey:@"en"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorView.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.2f];
    if(indexPath.row == (cancelationReasonsArray.count - 1))
        [cell.separatorView setHidden:YES];
    if(selectedReasonIndex == [[NSNumber numberWithInteger:indexPath.row] intValue])
        [cell.rightCheckMarkImg setHidden:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//    CancelationReasonsTableViewCell *cell = (CancelationReasonsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    [cell bringSubviewToFront:cell.separatorView];
//    [cell.contentView bringSubviewToFront:cell.separatorView];
    selectedReasonIndex = [[NSNumber numberWithInteger:indexPath.row] intValue];
    [_reasonsTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)cancelOnRide:(UIButton *)sender {
    [self.delegate cancelActionWithReason:[[cancelationReasonsArray objectAtIndex:selectedReasonIndex] objectForKey:@"en"]];
}

@end

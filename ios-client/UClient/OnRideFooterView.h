//
//  OnRideFooterView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CancelationReasonsTableViewCell.h"
#import "UIHelperClass.h"

@protocol OnRideFooterViewDelegate <NSObject>
@required
-(void)cancelActionWithReason:(NSString *)reasonString;
-(void)callDriverPhone;
@end

@interface OnRideFooterView : UIView {
    
    UIPanGestureRecognizer *onRideFooterPanGesture;
    
    NSArray *cancelationReasonsArray;
    
    IBOutlet CancelationReasonsTableViewCell *defaultCell;
    
    float initialYAfterPan;
    float initialY;
    
    int selectedReasonIndex;
}

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic, weak) id <OnRideFooterViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *onRideCancelConfirmBGView;
@property (weak, nonatomic) IBOutlet UIView *canceledRideView;

@property (weak, nonatomic) IBOutlet UIImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vehicleImageView;

@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverRateLabel;
@property (weak, nonatomic) IBOutlet UITableView *reasonsTableView;

- (IBAction)cancelOnRide:(UIButton *)sender;

-(instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)reasonsArray;

- (IBAction)callBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@end

//
//  InitiatedRideFooterView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/26/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIHelperClass.h"

#import "M13ProgressView.h"
#import "M13ProgressViewStripedBar.h"
#import "M13ProgressViewBar.h"

@protocol InitiatedRideFooterViewDelegate <NSObject>
@required
-(void)cancelAction;
@end

@interface InitiatedRideFooterView : UIView {
    UIPanGestureRecognizer *initiatedFooterPanGesture;
    float initialY;
    float initialYAfterPan;
}
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, weak) id <InitiatedRideFooterViewDelegate> delegate;

#pragma mark - initiated Ride Footer View
@property (weak, nonatomic) IBOutlet UIView *initiatedCancelConfirmationView;

@property (strong, nonatomic) M13ProgressViewStripedBar *progressView;

@property (weak, nonatomic) IBOutlet UIButton *initialCancelBtn;
- (IBAction)initiatedCancelAction:(UIButton *)sender;
- (IBAction)confirminitiatedCancelButtonAction:(UIButton *)sender;
- (IBAction)notConfirminitiatedCancelBtnAction:(UIButton *)sender;

-(void)showCustomLoadingView:(BOOL)show;

@end

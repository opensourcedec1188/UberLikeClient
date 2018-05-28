//
//  MenuView.h
//  Ego
//
//  Created by Mahmoud Amer on 8/1/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ServiceManager.h"
#import "ProfileServiceManager.h"
#import "HelperClass.h"
#import "UIHelperClass.h"

@protocol MenuViewDelegate <NSObject>

@required
-(void)performSegue:(NSString *)segueIdentifier;
-(void)hideMe;
-(void)presentViewController:(NSString *)storyboardID;
@end

@interface MenuView : UIView {
    NSDictionary *clientData;
    
}
@property (nonatomic, weak) id <MenuViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

@property (weak, nonatomic) IBOutlet UIView *clientBGImgView;
@property (weak, nonatomic) IBOutlet UIImageView *clientImageView;
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIButton *profileBtn;
@property (weak, nonatomic) IBOutlet UIButton *paymentBtn;
@property (weak, nonatomic) IBOutlet UIButton *rideHistoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *promosBtn;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;


- (IBAction)profileAction:(UIButton *)sender;
- (IBAction)ridesHistoryAction:(UIButton *)sender;
- (IBAction)goPaymentAction:(UIButton *)sender;
- (IBAction)goSettingsAction:(UIButton *)sender;
- (IBAction)goHelpAction:(UIButton *)sender;
- (IBAction)goPromosAction:(UIButton *)sender;

- (IBAction)dismissAction:(UIButton *)sender;
@end

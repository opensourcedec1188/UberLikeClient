//
//  MenuView.m
//  Ego
//
//  Created by Mahmoud Amer on 8/1/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView

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
    [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    clientData = [ServiceManager getClientDataFromUserDefaults];
    
    _clientImageView.layer.cornerRadius = _clientImageView.frame.size.height / 2;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"clientImageData"])
        [_clientImageView setImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"clientImageData"]]];
    else{
        NSString *clientPhotoURL = [clientData objectForKey:@"photoUrl"];
        [_clientImageView setImageWithURL:[NSURL URLWithString:clientPhotoURL] placeholderImage:[UIImage imageNamed:@"driver_placeholder.png"]];
    }
    
    _clientImageView.layer.masksToBounds = YES;
    
    _clientBGImgView.layer.cornerRadius = _clientBGImgView.frame.size.height / 2;
    UIBezierPath *clientBGShadowPath = [UIHelperClass setViewShadow:_clientBGImgView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:30.0f];
    _clientBGImgView.layer.shadowPath = clientBGShadowPath.CGPath;
    
    _clientNameLabel.text = [clientData objectForKey:@"firstName"];
    _ratingLabel.text = [NSString stringWithFormat:@"%.2f", [[clientData objectForKey:@"ratingsAvg"] floatValue]];
    
}

- (IBAction)profileAction:(UIButton *)sender {
//    [self.delegate performSegue:@"myProfileSegue"];
    [[self delegate] presentViewController:@"ProfileController"];
}

- (IBAction)ridesHistoryAction:(UIButton *)sender {
//    [self.delegate performSegue:@"ridesHistorySegue"];
    [[self delegate] presentViewController:@"RideHistory"];
}

- (IBAction)goPaymentAction:(UIButton *)sender {
//    [[self delegate] performSegue:@"homeGoPaymentSegue"];
    [[self delegate] presentViewController:@"PaymentController"];
}

- (IBAction)goSettingsAction:(UIButton *)sender {
//    [self.delegate performSegue:@"homeGoSettings"];
    [[self delegate] presentViewController:@"SettingsController"];
}

- (IBAction)goHelpAction:(UIButton *)sender {
//    [self.delegate performSegue:@"homeGoHelpSegue"];
    [[self delegate] presentViewController:@"HelpNavController"];
}

- (IBAction)goPromosAction:(UIButton *)sender {
//    [[self delegate] performSegue:@"HomeGoPromos"];
    [[self delegate] presentViewController:@"PromosController"];
}

- (IBAction)dismissAction:(UIButton *)sender {
    [self.delegate hideMe];
}

#
@end

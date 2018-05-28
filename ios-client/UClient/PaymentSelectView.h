//
//  PaymentSelectView.h
//  Ego
//
//  Created by Mahmoud Amer on 7/25/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaymentSelectViewDelegate <NSObject>

@required
-(void)dismissPaymentView;
@end


@interface PaymentSelectView : UIView {
    
}


@property (nonatomic, weak) id <PaymentSelectViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

- (IBAction)hideMeAction:(UIButton *)sender;
@end

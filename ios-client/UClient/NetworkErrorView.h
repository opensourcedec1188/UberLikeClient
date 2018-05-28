//
//  NetworkErrorView.h
//  Ego
//
//  Created by Mahmoud Amer on 8/13/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NetworkErrorViewDelegate <NSObject>

@required
-(void)hideNetworkErrorView;
@end

@interface NetworkErrorView : UIView {
    
}
@property (nonatomic, weak) id <NetworkErrorViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *CONTENTVIEW;

- (IBAction)dismissBtnAction:(UIButton *)sender;
@end

//
//  CustomTextField.h
//  Ego
//
//  Created by MacBookPro on 4/15/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTextFieldDelegate <NSObject>
@required
-(void)handleDelete:(UITextField *)textField;
@end

@interface CustomTextField : UITextField

@property (nonatomic, weak) id <CustomTextFieldDelegate> customTFDelegate;

@end

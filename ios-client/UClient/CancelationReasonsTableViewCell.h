//
//  CancelationReasonsTableViewCell.h
//  Ego
//
//  Created by Mahmoud Amer on 7/27/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CancelationReasonsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIImageView *rightCheckMarkImg;

@end

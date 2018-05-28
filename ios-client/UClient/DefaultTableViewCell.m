//
//  DefaultTableViewCell.m
//  Ego
//
//  Created by Mahmoud Amer on 6/12/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "DefaultTableViewCell.h"

@implementation DefaultTableViewCell
//@synthesize titleLabel = _titleLabel;
//@synthesize iconImageView = _iconImageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)rightFavBtnAction:(UIButton *)sender {
    NSLog(@"fav : %i", [[NSNumber numberWithInteger:sender.tag] intValue]);
    [self.delegate setFavourite:[[NSNumber numberWithInteger:sender.tag] intValue]];
}
@end

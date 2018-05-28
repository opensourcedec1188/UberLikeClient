//
//  DefaultTableViewCell.h
//  Ego
//
//  Created by Mahmoud Amer on 6/12/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DefaultTableViewCellDelegate <NSObject>
@required
-(void)setFavourite:(int)selectedRow;
@end

@interface DefaultTableViewCell : UITableViewCell {
    
}

@property (nonatomic, weak) id <DefaultTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLBL;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;
@property (weak, nonatomic) IBOutlet UIButton *rightFavBtn;
- (IBAction)rightFavBtnAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *separatorView;
@end

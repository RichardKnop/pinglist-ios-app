//
//  AlarmTableViewCell.m
//  Pinglist
//
//  Created by admin on 5/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AlarmTableViewCell.h"

@implementation AlarmTableViewCell

- (void)awakeFromNib {
    self.lblHttpCode.font   =   [UIFont fontWithName:@"Lato-Bold" size:15.0f];
    self.lblInterval.font   =   [UIFont fontWithName:@"Lato-Bold" size:15.0f];
    self.lblRegion.font     =   [UIFont fontWithName:@"Lato-Bold" size:15.0f];
    self.lblUrl.font        =   [UIFont fontWithName:@"Lato-Regular" size:12.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onLock:(id)sender {
    if (self.isLocked)
        [self.btnLock setImage:[UIImage imageNamed:@"unlocked"] forState:UIControlStateNormal];

    else
        [self.btnLock setImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
    
    self.isLocked = !self.isLocked;
    self.btnSwitch.userInteractionEnabled = !self.isLocked;
}

- (IBAction)onArrow:(id)sender {
    if (!self.isExpanded) {
        
        [UIView animateWithDuration:.2f animations:^{
            self.vwBackground.frame = CGRectMake(0, self.vwBackground.frame.origin.y, self.vwBackground.frame.size.width, self.vwBackground.frame.size.height);
        } completion:^(BOOL finished) {
            [self.btnArrow setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
        }];
    }
    
    else {
        
        [UIView animateWithDuration:.2f animations:^{
            self.vwBackground.frame = CGRectMake(-50, self.vwBackground.frame.origin.y, self.vwBackground.frame.size.width, self.vwBackground.frame.size.height);
        } completion:^(BOOL finished) {
            [self.btnArrow setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
        }];
    }
    
    self.isExpanded = !self.isExpanded;
}
@end

//
//  MemberTableViewCell.m
//  Pinglist
//
//  Created by admin on 5/11/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Global.h"
#import "MemberTableViewCell.h"

@implementation MemberTableViewCell

- (void)awakeFromNib {
  // Initialization code
  self.lblMember.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.lblMember.textColor = GREEN_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end

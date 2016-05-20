//
//  TeamTableViewCell.m
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TeamTableViewCell.h"
#import "Global.h"

@implementation TeamTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.lblTeamName.font       =   [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.lblTeamName.textColor  =   GREEN_COLOR;
    self.lblNumber.font         =   [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

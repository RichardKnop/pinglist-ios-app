//
//  IncidentTableViewCell.m
//  Pinglist
//
//  Created by admin on 5/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "IncidentTableViewCell.h"

@implementation IncidentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.lblType.font           =   [UIFont fontWithName:@"Lato-Medium" size:15.0f];
    self.lblOccurred.font       =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblResolvedAt.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

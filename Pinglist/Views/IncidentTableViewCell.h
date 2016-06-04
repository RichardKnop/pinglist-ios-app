//
//  IncidentTableViewCell.h
//  Pinglist
//
//  Created by admin on 5/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncidentTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *lblType;
@property(weak, nonatomic) IBOutlet UILabel *lblOccurred;
@property(weak, nonatomic) IBOutlet UILabel *lblResolvedAt;
@property(weak, nonatomic) IBOutlet UIButton *btnView;

@end

//
//  TeamTableViewCell.h
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *lblTeamName;
@property(weak, nonatomic) IBOutlet UILabel *lblNumber;
@property(weak, nonatomic) IBOutlet UIButton *btnEdit;
@property(weak, nonatomic) IBOutlet UIButton *btnDelete;

@end

//
//  MemberTableViewCell.h
//  Pinglist
//
//  Created by admin on 5/11/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel    *lblMember;
@property (weak, nonatomic) IBOutlet UIButton   *btnDelete;

@end

//
//  AlarmTableViewCell.h
//  Pinglist
//
//  Created by admin on 5/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface AlarmTableViewCell : UITableViewCell

- (IBAction)onLock:(id)sender;
- (IBAction)onArrow:(id)sender;

@property (nonatomic, strong)       NSString        *alarmStatus;
@property                           BOOL            isInactive;
@property                           BOOL            isLocked;
@property                           BOOL            isExpanded;

@property (weak, nonatomic) IBOutlet UIImageView    *statusBar;
@property (weak, nonatomic) IBOutlet UIImageView    *statusIcon;
@property (weak, nonatomic) IBOutlet UILabel        *lblUrl;
@property (weak, nonatomic) IBOutlet UILabel        *lblRegion;
@property (weak, nonatomic) IBOutlet UILabel        *lblHttpCode;
@property (weak, nonatomic) IBOutlet UILabel        *lblInterval;
@property (weak, nonatomic) IBOutlet UIView         *vwBackground;
@property (weak, nonatomic) IBOutlet UIButton       *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton       *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton       *btnSwitch;
@property (weak, nonatomic) IBOutlet UIButton       *btnLock;
@property (weak, nonatomic) IBOutlet UIButton       *btnArrow;
@property (weak, nonatomic) IBOutlet UIButton       *btnPerformance;

@end

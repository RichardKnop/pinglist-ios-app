//
//  AlarmViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "EditAlarmViewController.h"
#import "Global.h"
#import <UIKit/UIKit.h>

@interface AlarmViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UIScrollViewDelegate, addAlarmDelegate,
                        editAlarmDelegate> {
  NSMutableArray *alarms;
  UIImage *stateIcon;
  UIColor *stateColor;
  NSString *pagingUrl;
  Alarm *selectedAlarm;
  UIRefreshControl *refreshControl;
}

- (IBAction)onMenu:(id)sender;

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@end

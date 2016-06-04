//
//  TeamViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AddTeamViewController.h"
#import "EditTeamViewController.h"
#import "Global.h"
#import <UIKit/UIKit.h>

@interface TeamViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UIScrollViewDelegate, addTeamDelegate,
                        editTeamDelegate> {
  NSMutableArray *teams;
  NSString *pagingUrl;
  Team *selectedTeam;
  UIRefreshControl *refreshControl;
}

- (IBAction)onMenu:(id)sender;

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@end

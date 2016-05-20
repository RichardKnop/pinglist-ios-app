//
//  EditTeamViewController.h
//  Pinglist
//
//  Created by admin on 5/11/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@protocol editTeamDelegate
- (void)refreshEditTeam;
@end

@interface EditTeamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray  *members;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onAdd:(id)sender;
- (IBAction)onSubmit:(id)sender;

@property (nonatomic, strong)        Team           *team;
@property                            id             <editTeamDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITextField    *txtFieldTeamname;
@property (weak, nonatomic) IBOutlet UITextField    *txtFieldMember;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UILabel        *lblCaption;
@property (weak, nonatomic) IBOutlet UILabel        *lblAdded;

@end

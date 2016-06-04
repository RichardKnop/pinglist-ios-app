//
//  AlarmViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AlarmViewController.h"
#import "Global.h"
#import "PerformanceViewController.h"

@interface AlarmViewController ()

@end

@implementation AlarmViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  alarms = [[NSMutableArray alloc] init];
  NSString *requestURL =
      [NSString stringWithFormat:@"/v1/alarms?limit=%d&order_by=id desc",
                                 alarmsPagingLimit];
  [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
  [self loadAlarms:requestURL];

  refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.tintColor = [UIColor whiteColor];
  [refreshControl addTarget:self
                     action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  [self.scrollView addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Load Alarms

- (void)refresh {
  alarms = [[NSMutableArray alloc] init];
  NSString *requestURL =
      [NSString stringWithFormat:@"/v1/alarms?limit=%d&order_by=id desc",
                                 alarmsPagingLimit];
  [self loadAlarms:requestURL];
}

- (void)loadAlarms:(NSString *)requestURL {
  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self loadAlarms:requestURL];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  NSString *encodedURL = [NSString
      stringWithFormat:@"%@%@", endpointURL,
                       [requestURL
                           stringByAddingPercentEncodingWithAllowedCharacters:
                               [NSCharacterSet URLQueryAllowedCharacterSet]]];

  [[Global afManager] GET:encodedURL
      parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        [refreshControl endRefreshing];

        NSArray *array = responseObject[@"_embedded"][@"alarms"];
        pagingUrl = responseObject[@"_links"][@"next"][@"href"];

        for (int i = 0; i < array.count; i++) {
          Alarm *alrm = [[Alarm alloc] initWithData:array[i]];
          [alarms addObject:alrm];
        }

        [self.tableView reloadData];
        self.tableView.frame =
            CGRectMake(self.tableView.frame.origin.x, 0,
                       self.tableView.frame.size.width, 145 * alarms.count);
        if (self.tableView.frame.size.height <
            self.scrollView.frame.size.height) {
          self.scrollView.contentSize =
              CGSizeMake(self.scrollView.frame.size.width,
                         self.scrollView.frame.size.height + 50);
        } else
          self.scrollView.contentSize =
              CGSizeMake(self.scrollView.frame.size.width, 145 * alarms.count);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *response = [NSJSONSerialization
            JSONObjectWithData:
                (NSData *)error.userInfo
                    [AFNetworkingOperationFailingURLResponseDataErrorKey]
                       options:kNilOptions
                         error:&error];
        [SVProgressHUD showErrorWithStatus:response[@"error"]
                                  maskType:SVProgressHUDMaskTypeClear];
      }];
}

- (UIImage *)getStatusIcon:(NSString *)string {
  if ([string isEqualToString:@"ok"]) {
    stateColor = GREEN_COLOR;
    stateIcon = [UIImage imageNamed:@"status_ok"];
  }

  else if ([string isEqualToString:@"alarm"]) {
    stateColor = RED_COLOR;
    stateIcon = [UIImage imageNamed:@"status_alarm"];
  }

  else {
    stateColor = YELLOW_COLOR;
    stateIcon = [UIImage imageNamed:@"status_insufficient"];
  }

  return stateIcon;
}

#pragma mark - Menu button action

- (IBAction)onMenu:(id)sender {
  [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AlarmTableViewCell *cell = (AlarmTableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:@"alarm_cell"];
  Alarm *alarm = alarms[indexPath.row];
  [self getStatusIcon:alarm.state];

  cell.isLocked = YES;
  cell.alarmStatus = alarm.state;
  cell.isInactive = !alarm.isActive;
  cell.lblRegion.text = alarm.region;
  cell.lblHttpCode.text =
      [NSString stringWithFormat:@"%d", alarm.expected_http_code];
  cell.lblInterval.text = [NSString stringWithFormat:@"%d", alarm.interval];
  cell.lblUrl.text = alarm.endpoint_url;
  cell.statusBar.backgroundColor = stateColor;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;

  if (cell.isInactive) {
    cell.statusBar.backgroundColor = GREY_COLOR;
    cell.statusIcon.image = [UIImage imageNamed:@"status_inactive"];
    [cell.btnSwitch setImage:[UIImage imageNamed:@"off"]
                    forState:UIControlStateNormal];
  }

  else {
    if ([cell.alarmStatus isEqualToString:@"ok"]) {
      cell.statusBar.backgroundColor = GREEN_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_ok"];
    }

    if ([cell.alarmStatus isEqualToString:@"alarm"]) {
      cell.statusBar.backgroundColor = RED_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_alarm"];
    }

    if ([cell.alarmStatus isEqualToString:@"insufficient data"]) {
      cell.statusBar.backgroundColor = YELLOW_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_insufficient"];
    }
  }
  cell.btnSwitch.userInteractionEnabled = !cell.isLocked;
  cell.btnSwitch.tag = indexPath.row;
  cell.btnEdit.tag = indexPath.row;
  cell.btnDelete.tag = indexPath.row;
  cell.btnPerformance.tag = indexPath.row;

  [cell.btnSwitch addTarget:self
                     action:@selector(onSwitch:)
           forControlEvents:UIControlEventTouchUpInside];
  [cell.btnEdit addTarget:self
                   action:@selector(onEdit:)
         forControlEvents:UIControlEventTouchUpInside];
  [cell.btnDelete addTarget:self
                     action:@selector(onDelete:)
           forControlEvents:UIControlEventTouchUpInside];
  [cell.btnPerformance addTarget:self
                          action:@selector(onPerformance:)
                forControlEvents:UIControlEventTouchUpInside];

  return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  selectedAlarm = alarms[indexPath.row];
  [self performSegueWithIdentifier:@"performance" sender:self];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  float y = self.scrollView.contentOffset.y;
  float offset =
      self.scrollView.contentSize.height - self.scrollView.frame.size.height;

  if (y >= offset) {
    if (![pagingUrl isEqualToString:@""]) {
      [SVProgressHUD showWithStatus:@"Load more"
                           maskType:SVProgressHUDMaskTypeClear];
      [self loadAlarms:pagingUrl];
    }
  }
}

#pragma mark - Actions for alarm

- (void)onSwitch:(id)sender {
  selectedAlarm = alarms[[sender tag]];
  AlarmTableViewCell *cell = [self.tableView
      cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[sender tag]
                                               inSection:0]];
  if (cell.isLocked) {
    return;
  }

  if (!cell.isInactive) {
    [cell.btnSwitch setImage:[UIImage imageNamed:@"off"]
                    forState:UIControlStateNormal];
    cell.statusBar.backgroundColor = GREY_COLOR;
    cell.statusIcon.image = [UIImage imageNamed:@"status_inactive"];
  }

  else {
    [cell.btnSwitch setImage:[UIImage imageNamed:@"on"]
                    forState:UIControlStateNormal];

    if ([cell.alarmStatus isEqualToString:@"ok"]) {
      cell.statusBar.backgroundColor = GREEN_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_ok"];
    }

    if ([cell.alarmStatus isEqualToString:@"alarm"]) {
      cell.statusBar.backgroundColor = RED_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_alarm"];
    }

    if ([cell.alarmStatus isEqualToString:@"insufficient data"]) {
      cell.statusBar.backgroundColor = YELLOW_COLOR;
      cell.statusIcon.image = [UIImage imageNamed:@"status_insufficient"];
    }
  }

  cell.isInactive = !cell.isInactive;

  // Update alarm status

  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self onSwitch:sender];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  NSString *requestURL = [NSString
      stringWithFormat:@"%@/v1/alarms/%d", endpointURL, selectedAlarm.ID];
  NSDictionary *params = @{
    @"region" : selectedAlarm.region,
    @"endpoint_url" : selectedAlarm.endpoint_url,
    @"expected_http_code" :
        [NSNumber numberWithInt:selectedAlarm.expected_http_code],
    @"max_response_time" :
        [NSNumber numberWithInt:selectedAlarm.max_response_time],
    @"interval" : [NSNumber numberWithInt:selectedAlarm.interval],
    @"email_alerts" : [NSNumber numberWithBool:selectedAlarm.isEmailAlert],
    @"push_notification_alerts" :
        [NSNumber numberWithBool:selectedAlarm.isPushNotification],
    @"active" : [NSNumber numberWithBool:!cell.isInactive],
    @"state" : selectedAlarm.state
  };

  [SVProgressHUD showWithStatus:@"Updating"
                       maskType:SVProgressHUDMaskTypeClear];
  [[Global afManager] PUT:requestURL
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *respone = [NSJSONSerialization
            JSONObjectWithData:
                (NSData *)error.userInfo
                    [AFNetworkingOperationFailingURLResponseDataErrorKey]
                       options:kNilOptions
                         error:&error];
        [SVProgressHUD showErrorWithStatus:respone[@"error"]
                                  maskType:SVProgressHUDMaskTypeClear];
      }];
}

- (void)onEdit:(id)sender {
  selectedAlarm = alarms[[sender tag]];
  [self performSegueWithIdentifier:@"edit_alarm" sender:self];
}

- (void) delete:(Alarm *)alarm {
  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self delete:alarm];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/alarms/%d", endpointURL, alarm.ID];
  [SVProgressHUD showWithStatus:@"Deleting"
                       maskType:SVProgressHUDMaskTypeClear];

  [[Global afManager] DELETE:requestURL
      parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [alarms removeObject:alarm];

        [self.tableView reloadData];
        self.tableView.frame =
            CGRectMake(self.tableView.frame.origin.x, 0,
                       self.tableView.frame.size.width, 145 * alarms.count);
        self.scrollView.contentSize =
            CGSizeMake(self.scrollView.frame.size.width, 145 * alarms.count);

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *respone = [NSJSONSerialization
            JSONObjectWithData:
                (NSData *)error.userInfo
                    [AFNetworkingOperationFailingURLResponseDataErrorKey]
                       options:kNilOptions
                         error:&error];
        [SVProgressHUD showErrorWithStatus:respone[@"error"]
                                  maskType:SVProgressHUDMaskTypeClear];
      }];
}

- (void)onDelete:(id)sender {

  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:nil
                       message:@"Are you sure you want to delete the alarm?"
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *yes =
      [UIAlertAction actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
                               Alarm *alrm = alarms[[sender tag]];
                               [self delete:alrm];
                             }];

  UIAlertAction *no = [UIAlertAction
      actionWithTitle:@"No"
                style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *_Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
              }];

  [alert addAction:yes];
  [alert addAction:no];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)onPerformance:(id)sender {
  selectedAlarm = alarms[[sender tag]];
  [self performSegueWithIdentifier:@"performance" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"edit_alarm"]) {
    EditAlarmViewController *edit = segue.destinationViewController;
    edit.alarm = selectedAlarm;
    edit.delegate = self;
  }

  else if ([segue.identifier isEqualToString:@"performance"]) {
    PerformanceViewController *perf = segue.destinationViewController;
    perf.alarm = selectedAlarm;
  }

  else {
    AddAlarmViewController *add = segue.destinationViewController;
    add.delegate = self;
  }
}

#pragma mark - refresh alarms (add, update)

- (void)refreshAddedAlarm {
  [self refresh];
}

- (void)refreshUpdatedAlarm {
  [self refresh];
}

@end

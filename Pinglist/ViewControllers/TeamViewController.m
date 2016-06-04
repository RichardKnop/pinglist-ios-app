//
//  TeamViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TeamViewController.h"

@interface TeamViewController ()

@end

@implementation TeamViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  teams = [[NSMutableArray alloc] init];

  // Load teams
  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/teams?order_by=id desc", endpointURL];
  [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
  [self loadTeam:requestURL];

  // Pull to refresh
  refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.tintColor = [UIColor whiteColor];
  [refreshControl addTarget:self
                     action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  [self.scrollView addSubview:refreshControl];
}

- (void)refresh {
  teams = [[NSMutableArray alloc] init];
  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/teams?order_by=id desc", endpointURL];
  [self loadTeam:requestURL];
}

- (void)loadTeam:(NSString *)url {
  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self loadTeam:url];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  NSString *encodedURL =
      [url stringByAddingPercentEncodingWithAllowedCharacters:
               [NSCharacterSet URLQueryAllowedCharacterSet]];

  [[Global afManager] GET:encodedURL
      parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        [refreshControl endRefreshing];

        NSArray *array = responseObject[@"_embedded"][@"teams"];
        pagingUrl = responseObject[@"_links"][@"next"][@"href"];

        for (int i = 0; i < array.count; i++) {
          Team *t = [[Team alloc] initWithData:array[i]];
          [teams addObject:t];
        }

        [self.tableView reloadData];

        self.tableView.frame =
            CGRectMake(self.tableView.frame.origin.x, 0,
                       self.tableView.frame.size.width, 95 * teams.count);
        if (self.tableView.frame.size.height <
            self.scrollView.frame.size.height) {
          self.scrollView.contentSize =
              CGSizeMake(self.scrollView.frame.size.width,
                         self.scrollView.frame.size.height + 50);
        } else
          self.scrollView.contentSize =
              CGSizeMake(self.scrollView.frame.size.width, 95 * teams.count);

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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onMenu:(id)sender {
  [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (void) delete:(Team *)t {
  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self delete:t];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/teams/%d", endpointURL, t.ID];

  [SVProgressHUD showWithStatus:@"Deleting"
                       maskType:SVProgressHUDMaskTypeClear];
  [[Global afManager] DELETE:requestURL
      parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [teams removeObject:t];

        [self.tableView reloadData];
        self.tableView.frame =
            CGRectMake(0, 0, self.tableView.frame.size.width, 95 * teams.count);
        self.scrollView.contentSize =
            CGSizeMake(self.scrollView.frame.size.width, 95 * teams.count);

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
                       message:@"Are you sure you want to delete the team?"
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *yes =
      [UIAlertAction actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
                               Team *t = teams[[sender tag]];
                               [self delete:t];
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

- (void)onEdit:(id)sender {
  selectedTeam = teams[[sender tag]];
  [self performSegueWithIdentifier:@"edit_team" sender:self];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  TeamTableViewCell *cell = (TeamTableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:@"team"];
  Team *team = teams[indexPath.row];

  cell.lblTeamName.text = team.name;
  NSLog(@"%@", team.members);
  cell.lblNumber.text = @(team.members.count).stringValue;

  cell.btnEdit.tag = indexPath.row;
  cell.btnDelete.tag = indexPath.row;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.backgroundColor = [UIColor clearColor];

  [cell.btnEdit addTarget:self
                   action:@selector(onEdit:)
         forControlEvents:UIControlEventTouchUpInside];
  [cell.btnDelete addTarget:self
                     action:@selector(onDelete:)
           forControlEvents:UIControlEventTouchUpInside];

  return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  float y = self.scrollView.contentOffset.y;
  float offset =
      self.scrollView.contentSize.height - self.scrollView.frame.size.height;

  if (y >= offset) {
    if (![pagingUrl isEqualToString:@""]) {
      [SVProgressHUD showWithStatus:@"Loading"
                           maskType:SVProgressHUDMaskTypeClear];
      [self loadTeam:pagingUrl];
    }
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"add_team"]) {
    AddTeamViewController *team = segue.destinationViewController;
    team.delegate = self;
  }

  else {
    EditTeamViewController *team = segue.destinationViewController;
    team.team = selectedTeam;
    team.delegate = self;
  }
}

#pragma mark - Refresh Team list

- (void)refreshAddTeam {
  [self refresh];
}

- (void)refreshEditTeam {
  [self refresh];
}

@end

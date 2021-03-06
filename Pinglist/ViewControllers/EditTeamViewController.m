//
//  EditTeamViewController.m
//  Pinglist
//
//  Created by admin on 5/11/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "EditTeamViewController.h"
#import "MemberTableViewCell.h"

@interface EditTeamViewController ()

@end

@implementation EditTeamViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.txtFieldMember.font = [UIFont fontWithName:@"Lato-Regular" size:15.0f];
  self.lblCaption.font = [UIFont fontWithName:@"Lato-Regular" size:30.0f];
  self.lblAdded.font = [UIFont fontWithName:@"Lato-Regular" size:20.0f];
  self.txtFieldTeamname.font = [UIFont fontWithName:@"Lato-Regular" size:15.0f];
  self.txtFieldMember.textColor = GREEN_COLOR;
  self.txtFieldTeamname.textColor = GREEN_COLOR;
  self.lblCaption.textColor = GREEN_COLOR;

  [Global changePlaceholderTextColor:self.txtFieldTeamname
                                text:@"Team Name"
                               color:GREEN_COLOR];
  [Global changePlaceholderTextColor:self.txtFieldMember
                                text:@"Email Address"
                               color:GREEN_COLOR];

  members = [[NSMutableArray alloc] init];
  self.txtFieldTeamname.text = self.team.name;
  NSArray *array = self.team.members;

  for (int i = 0; i < array.count; i++) {
    NSDictionary *dict = array[i];
    [members addObject:dict[@"email"]];
  }

  [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.txtFieldMember resignFirstResponder];
  [self.txtFieldTeamname resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAdd:(id)sender {
  if (![Global validateEmail:self.txtFieldMember.text]) {
    [Global showAlert:@"Invalid email address" sender:self];
    return;
  }

  [members addObject:self.txtFieldMember.text];
  [self.tableView reloadData];
  self.txtFieldMember.text = @"";
}

- (IBAction)onSubmit:(id)sender {
  if ([self.txtFieldTeamname.text isEqualToString:@""]) {
    [Global showAlert:@"Please enter the team name" sender:self];
    return;
  }

  NSMutableArray *emails = [[NSMutableArray alloc] init];
  for (int i = 0; i < members.count; i++) {
    NSDictionary *didct = @{ @"email" : members[i] };
    [emails addObject:didct];
  }

  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self onSubmit:sender];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  [SVProgressHUD showWithStatus:@"Update" maskType:SVProgressHUDMaskTypeClear];
  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/teams/%d", endpointURL, self.team.ID];
  NSDictionary *params = @{
    @"name" : self.txtFieldTeamname.text,
    @"members" : emails
  };

  [[Global afManager] PUT:requestURL
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.delegate refreshEditTeam];
        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MemberTableViewCell *cell = (MemberTableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:@"member"];
  cell.lblMember.text = members[indexPath.row];
  cell.btnDelete.tag = indexPath.row;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  [cell.btnDelete addTarget:self
                     action:@selector(onDelete:)
           forControlEvents:UIControlEventTouchUpInside];

  return cell;
}

- (void)onDelete:(id)sender {
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:nil
                       message:@"Are you sure you want to delete?"
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *yes =
      [UIAlertAction actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
                               [members removeObjectAtIndex:[sender tag]];
                               [self.tableView reloadData];
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

@end

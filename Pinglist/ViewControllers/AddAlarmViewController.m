//
//  AddAlarmViewController.m
//  Pinglist
//
//  Created by admin on 5/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "Global.h"

@interface AddAlarmViewController ()

@end

@implementation AddAlarmViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  locationName = @"Location";
  locations = [[NSMutableArray alloc] init];

  for (int i = 0; i < [Global sharedInstance].locations.count; i++) {
    Location *location = [Global sharedInstance].locations[i];
    [locations addObject:location.location_name];
  }

  self.txtFieldHttpCode.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldInterval.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldMaxResponseTime.font =
      [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldUrl.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.btnLocation.titleLabel.font =
      [UIFont fontWithName:@"Lato-Regular" size:14.0f];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.txtFieldHttpCode resignFirstResponder];
  [self.txtFieldInterval resignFirstResponder];
  [self.txtFieldMaxResponseTime resignFirstResponder];
  [self.txtFieldUrl resignFirstResponder];

  self.view.frame =
      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Button action

- (IBAction)onBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCreate:(id)sender {
  if (![Global validateInteger:self.txtFieldInterval.text]) {
    [Global showAlert:@"Please enter an interval" sender:self];
    return;
  }

  if (![Global validateInteger:self.txtFieldMaxResponseTime.text]) {
    [Global showAlert:@"Please enter a max response time" sender:self];
    return;
  }

  if (![Global validateInteger:self.txtFieldHttpCode.text]) {
    [Global showAlert:@"Please enter an HTTP code" sender:self];
    return;
  }

  if (self.txtFieldUrl.text.length == 0) {
    [Global showAlert:@"Please enter a URL" sender:self];
    return;
  }

  if ([locationName isEqualToString:@"Location"]) {
    [Global showAlert:@"Please select a location" sender:self];
    return;
  }

  if (![Global validateUrl:self.txtFieldUrl.text]) {
    [Global showAlert:@"Please enter a valid URL" sender:self];
    return;
  }

  httpCode = self.txtFieldHttpCode.text.intValue;
  url = self.txtFieldUrl.text;
  locationName = self.btnLocation.titleLabel.text;
  interval = self.txtFieldInterval.text.intValue;
  maxResponseTime = self.txtFieldMaxResponseTime.text.intValue;

  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/alarms", endpointURL];
  NSDictionary *params = @{
    @"region" : locationId,
    @"endpoint_url" : url,
    @"expected_http_code" : [NSNumber numberWithInt:httpCode],
    @"max_response_time" : [NSNumber numberWithInt:maxResponseTime],
    @"interval" : [NSNumber numberWithInt:interval],
    @"email_alerts" : [NSNumber numberWithBool:isEmail],
    @"push_notification_alerts" : [NSNumber numberWithBool:isPushNotification],
    @"slack_alerts" : [NSNumber numberWithBool:isSlack],
    @"active" : [NSNumber numberWithBool:isActive],
    @"state" : @"insufficient data"
  };

  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self onCreate:sender];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  [SVProgressHUD showWithStatus:@"Creating"
                       maskType:SVProgressHUDMaskTypeClear];
  [[Global afManager] POST:requestURL
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.delegate refreshAddedAlarm];
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

- (IBAction)onLocation:(id)sender {
  [self.txtFieldHttpCode resignFirstResponder];
  [self.txtFieldInterval resignFirstResponder];
  [self.txtFieldMaxResponseTime resignFirstResponder];
  [self.txtFieldUrl resignFirstResponder];

  if (!isDropDown) {
    dropDownLocation = [[DropDownListView alloc]
        initWithTitle:nil
              options:locations
                   xy:CGPointMake(self.btnLocation.frame.origin.x - 10,
                                  self.btnLocation.frame.origin.y +
                                      self.btnLocation.frame.size.height - 3)
                 size:CGSizeMake(self.btnLocation.frame.size.width + 34, 150)
           isMultiple:NO];
    dropDownLocation.delegate = self;
    [dropDownLocation showInView:self.view animated:NO];
    [dropDownLocation SetBackGroundDropDown_R:255 G:255 B:255 alpha:1];
  } else {
    [dropDownLocation fadeOut];
  }

  isDropDown = !isDropDown;
}

- (IBAction)onEmail:(id)sender {
  if (isEmail) {
    [self.btnEmail setBackgroundImage:nil forState:UIControlStateNormal];
  } else {
    [self.btnEmail setBackgroundImage:[UIImage imageNamed:@"check"]
                             forState:UIControlStateNormal];
  }

  isEmail = !isEmail;
}

- (IBAction)onActive:(id)sender {
  if (isActive) {
    [self.btnActive setBackgroundImage:nil forState:UIControlStateNormal];
  } else {
    [self.btnActive setBackgroundImage:[UIImage imageNamed:@"check"]
                              forState:UIControlStateNormal];
  }

  isActive = !isActive;
}

- (IBAction)onPushNotification:(id)sender {
  if (isPushNotification) {
    [self.btnPushNotification setBackgroundImage:nil
                                        forState:UIControlStateNormal];
  } else {
    [self.btnPushNotification setBackgroundImage:[UIImage imageNamed:@"check"]
                                        forState:UIControlStateNormal];
  }

  isPushNotification = !isPushNotification;
}

- (IBAction)onSlack:(id)sender {
  if (isSlack) {
    [self.btnSlack setBackgroundImage:nil forState:UIControlStateNormal];
  } else {
    [self.btnSlack setBackgroundImage:[UIImage imageNamed:@"check"]
                             forState:UIControlStateNormal];
  }

  isSlack = !isSlack;
}

#pragma mark - Dropdown Delegate

- (void)DropDownListView:(DropDownListView *)dropdownListView
        didSelectedIndex:(NSInteger)anIndex
                   array:(NSArray *)data {
  isDropDown = NO;
  locationName = data[anIndex];
  locationId =
      [(Location *)[Global sharedInstance].locations[anIndex] location_id];
  [self.btnLocation setTitle:locationName forState:UIControlStateNormal];
}

- (void)DropDownListViewDidCancel {
}

- (void)DropDownListView:(DropDownListView *)dropdownListView
                Datalist:(NSMutableArray *)ArryData {
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (IS_IPHONE_4) {
    self.view.frame = CGRectMake(0, -150, self.view.frame.size.width,
                                 self.view.frame.size.height);
  } else {
    self.view.frame = CGRectMake(0, -50, self.view.frame.size.width,
                                 self.view.frame.size.height);
  }
}

@end

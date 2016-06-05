//
//  EditAlarmViewController.m
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "EditAlarmViewController.h"

@interface EditAlarmViewController ()

@end

@implementation EditAlarmViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.txtFieldHttpCode.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldInterval.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldMaxResponseTime.font =
      [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.txtFieldUrl.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
  self.btnLocation.titleLabel.font =
      [UIFont fontWithName:@"Lato-Regular" size:14.0f];

  self.txtFieldHttpCode.text =
      [NSString stringWithFormat:@"%d", self.alarm.expected_http_code];
  self.txtFieldUrl.text = self.alarm.endpoint_url;
  self.txtFieldInterval.text =
      [NSString stringWithFormat:@"%d", self.alarm.interval];
  self.txtFieldMaxResponseTime.text =
      [NSString stringWithFormat:@"%d", self.alarm.max_response_time];

  isEmail = self.alarm.isEmailAlert;
  isPushNotification = self.alarm.isPushNotification;
  isSlack = self.alarm.isSlackAlert;
  isActive = self.alarm.isActive;
  locations = [[NSMutableArray alloc] init];

  // Getting location name, not id
  for (int i = 0; i < [Global sharedInstance].locations.count; i++) {
    Location *loc = [Global sharedInstance].locations[i];

    if ([loc.location_id isEqualToString:self.alarm.region]) {
      locationName = loc.location_name;
      locationId = loc.location_id;
      [self.btnLocation setTitle:loc.location_name
                        forState:UIControlStateNormal];
    }
  }

  for (int i = 0; i < [Global sharedInstance].locations.count; i++) {
    Location *location = [Global sharedInstance].locations[i];
    [locations addObject:location.location_name];
  }

  if (isEmail) {
    [self.btnEmail setBackgroundImage:[UIImage imageNamed:@"check"]
                             forState:UIControlStateNormal];
  } else {
    [self.btnEmail setBackgroundImage:nil forState:UIControlStateNormal];
  }

  if (isPushNotification) {
    [self.btnPushNotification setBackgroundImage:[UIImage imageNamed:@"check"]
                                        forState:UIControlStateNormal];
  } else {
    [self.btnPushNotification setBackgroundImage:nil
                                        forState:UIControlStateNormal];
  }

  if (isSlack) {
    [self.btnSlack setBackgroundImage:[UIImage imageNamed:@"check"]
                             forState:UIControlStateNormal];
  } else {
    [self.btnSlack setBackgroundImage:nil forState:UIControlStateNormal];
  }

  if (isActive) {
    [self.btnActive setBackgroundImage:[UIImage imageNamed:@"check"]
                              forState:UIControlStateNormal];
  } else {
    [self.btnActive setBackgroundImage:nil forState:UIControlStateNormal];
  }
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

- (IBAction)onUpdate:(id)sender {
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

  NSString *requestURL = [NSString
      stringWithFormat:@"%@/v1/alarms/%d", endpointURL, self.alarm.ID];
  NSDictionary *params = @{
    @"region" : locationId,
    @"endpoint_url" : url,
    @"expected_http_code" : [NSNumber numberWithInt:httpCode],
    @"max_response_time" : [NSNumber numberWithInt:maxResponseTime],
    @"interval" : [NSNumber numberWithInt:interval],
    @"email_alerts" : [NSNumber numberWithBool:isEmail],
    @"slack_alerts" : [NSNumber numberWithBool:isSlack],
    @"push_notification_alerts" : [NSNumber numberWithBool:isPushNotification],
    @"active" : [NSNumber numberWithBool:isActive],
    @"state" : @"insufficient data"
  };

  [SVProgressHUD showWithStatus:@"Updating"
                       maskType:SVProgressHUDMaskTypeClear];

  if ([Global sharedInstance].credential.isExpired) {
    [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
      [self onUpdate:sender];
    }
        failure:^(NSError *error) {
          [Global logout:self.navigationController];
        }];
    return;
  }

  [[Global afManager] PUT:requestURL
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.delegate refreshUpdatedAlarm];
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
  }

  else
    [self.btnEmail setBackgroundImage:[UIImage imageNamed:@"check"]
                             forState:UIControlStateNormal];

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

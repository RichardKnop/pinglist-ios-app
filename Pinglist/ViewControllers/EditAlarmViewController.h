//
//  EditAlarmViewController.h
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "DropDownListView.h"
#import "Global.h"
#import <UIKit/UIKit.h>

@protocol editAlarmDelegate
- (void)refreshUpdatedAlarm;
@end

@interface EditAlarmViewController
    : UIViewController <kDropDownListViewDelegate, UITextFieldDelegate> {
  NSString *locationName;
  NSString *locationId;
  NSMutableArray *locations;
  NSString *url;
  BOOL isEmail;
  BOOL isPushNotification;
  BOOL isSlack;
  BOOL isActive;
  BOOL isDropDown;
  int httpCode;
  int interval;
  int maxResponseTime;
  DropDownListView *dropDownLocation;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onUpdate:(id)sender;
- (IBAction)onLocation:(id)sender;
- (IBAction)onEmail:(id)sender;
- (IBAction)onActive:(id)sender;
- (IBAction)onPushNotification:(id)sender;
- (IBAction)onSlack:(id)sender;

@property(nonatomic, strong) Alarm *alarm;
@property id<editAlarmDelegate> delegate;
@property(weak, nonatomic) IBOutlet UIButton *btnLocation;
@property(weak, nonatomic) IBOutlet UIButton *btnEmail;
@property(weak, nonatomic) IBOutlet UIButton *btnActive;
@property(weak, nonatomic) IBOutlet UIButton *btnPushNotification;
@property(weak, nonatomic) IBOutlet UIButton *btnSlack;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldHttpCode;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldUrl;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldInterval;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldMaxResponseTime;

@end

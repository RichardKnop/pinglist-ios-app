//
//  Alarm.m
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Alarm.h"
#import "Global.h"

@implementation Alarm

- (id)initWithData:(NSDictionary *)dict {
  self.ID = [[dict safe_objectForKey:@"id"] intValue];
  self.region = [dict safe_objectForKey:@"region"];
  self.endpoint_url = [dict safe_objectForKey:@"endpoint_url"];
  self.expected_http_code =
      [[dict safe_objectForKey:@"expected_http_code"] intValue];
  self.max_response_time =
      [[dict safe_objectForKey:@"max_response_time"] intValue];
  self.interval = [[dict safe_objectForKey:@"interval"] intValue];
  self.isEmailAlert = [[dict safe_objectForKey:@"email_alerts"] boolValue];
  self.isSlackAlert = [[dict safe_objectForKey:@"slack_alerts"] boolValue];
  self.isPushNotification =
      [[dict safe_objectForKey:@"push_notification_alerts"] boolValue];
  self.isActive = [[dict safe_objectForKey:@"active"] boolValue];
  self.state = [dict safe_objectForKey:@"state"];
  return self;
}

@end

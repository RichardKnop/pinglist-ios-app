//
//  Incident.m
//  Pinglist
//
//  Created by admin on 5/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Global.h"
#import "Incident.h"

@implementation Incident

- (id)initWithData:(NSDictionary *)dict {
  self.ID = [[dict safe_objectForKey:@"id"] intValue];
  self.alarm_ID = [[dict safe_objectForKey:@"alarm_id"] intValue];
  self.http_code = [[dict safe_objectForKey:@"http_code"] intValue];
  self.response_time = [[dict safe_objectForKey:@"response_time"] intValue];
  self.type = [dict safe_objectForKey:@"type"];
  self.response = [dict safe_objectForKey:@"response"];
  self.error_message = [dict safe_objectForKey:@"error_message"];
  self.resolved_at = [dict safe_objectForKey:@"resolved_at"];
  self.created_at = [dict safe_objectForKey:@"created_at"];
  self.updated_at = [dict safe_objectForKey:@"updated_at"];

  return self;
}

@end

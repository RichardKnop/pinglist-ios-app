//
//  TeamMember.m
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Global.h"
#import "TeamMember.h"

@implementation TeamMember

- (id)initWithData:(NSDictionary *)dict {
  self.ID = [[dict safe_objectForKey:@"id"] intValue];
  self.confirmed = [[dict safe_objectForKey:@"confirmed"] boolValue];
  self.firstName = [dict safe_objectForKey:@"first_name"];
  self.lastName = [dict safe_objectForKey:@"last_name"];
  self.email = [dict safe_objectForKey:@"email"];
  self.createdAt = [dict safe_objectForKey:@"created_at"];
  self.updatedAt = [dict safe_objectForKey:@"updated_at"];
  self.role = [dict safe_objectForKey:@"role"];

  return self;
}

@end

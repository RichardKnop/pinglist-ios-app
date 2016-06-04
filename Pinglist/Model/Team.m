//
//  Team.m
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Global.h"
#import "Team.h"

@implementation Team

- (id)initWithData:(NSDictionary *)dict {
  self.ID = [[dict safe_objectForKey:@"id"] intValue];
  self.name = [dict safe_objectForKey:@"name"];
  self.createdAt = [dict safe_objectForKey:@"created_at"];
  self.updatedAt = [dict safe_objectForKey:@"updated_at"];
  self.members = [[NSMutableArray alloc]
      initWithArray:[[dict safe_objectForKey:@"_embedded"]
                        objectForKey:@"members"]];

  return self;
}

@end

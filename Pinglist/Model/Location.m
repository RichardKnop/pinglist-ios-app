//
//  Location.m
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "Global.h"
#import "Location.h"

@implementation Location

- (id)initWithData:(NSDictionary *)dict {
  self.location_id = [dict safe_objectForKey:@"id"];
  self.location_name = [dict safe_objectForKey:@"name"];
  return self;
}

@end

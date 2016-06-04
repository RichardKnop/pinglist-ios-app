//
//  Incident.h
//  Pinglist
//
//  Created by admin on 5/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Incident : NSObject

@property int ID;
@property int alarm_ID;
@property int http_code;
@property int response_time;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *response;
@property(nonatomic, strong) NSString *error_message;
@property(nonatomic, strong) NSString *created_at;
@property(nonatomic, strong) NSString *updated_at;
@property(nonatomic, strong) NSString *resolved_at;

- (id)initWithData:(NSDictionary *)dict;

@end

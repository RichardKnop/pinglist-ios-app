//
//  Alarm.h
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alarm : NSObject

@property int ID;
@property int expected_http_code;
@property int interval;
@property int max_response_time;
@property BOOL isEmailAlert;
@property BOOL isPushNotification;
@property BOOL isSlackAlert;
@property BOOL isActive;
@property(nonatomic, strong) NSString *region;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *endpoint_url;

- (id)initWithData:(NSDictionary *)dict;

@end

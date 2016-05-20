//
//  Location.h
//  Pinglist
//
//  Created by admin on 5/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, strong) NSString    *location_name;
@property (nonatomic, strong) NSString    *location_id;

- (id)initWithData :(NSDictionary *)dict;

@end

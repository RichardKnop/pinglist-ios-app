//
//  Team.h
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject

@property                     int            ID;
@property (nonatomic, strong) NSString       *name;
@property (nonatomic, strong) NSString       *createdAt;
@property (nonatomic, strong) NSString       *updatedAt;
@property (nonatomic, strong) NSMutableArray *members;

- (id)initWithData :(NSDictionary *)dict;

@end

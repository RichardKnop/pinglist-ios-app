//
//  TeamMember.h
//  Pinglist
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamMember : NSObject

@property                     int            ID;
@property                     BOOL           confirmed;
@property (nonatomic, strong) NSString       *email;
@property (nonatomic, strong) NSString       *firstName;
@property (nonatomic, strong) NSString       *lastName;
@property (nonatomic, strong) NSString       *role;
@property (nonatomic, strong) NSString       *createdAt;
@property (nonatomic, strong) NSString       *updatedAt;

- (id)initWithData :(NSDictionary *)dict;

@end

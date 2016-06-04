#import <Foundation/Foundation.h>

@interface NSDictionary (Utils)

- (id)safe_objectForKey:(id)aKey;
@end

@interface NSMutableDictionary (Utils)

- (id)getSafeDictionary;
@end

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

- (id)safe_objectForKey:(id)aKey {
  id object = [self valueForKey:aKey];

  if (object == [NSNull null] || [[self allKeys] count] == 0) {
    return nil;
  }

  return object;
}

@end

@implementation NSMutableDictionary (Utils)

- (id)getSafeDictionary {
  for (NSString *key in [self allKeys]) {
    if ([self safe_objectForKey:key] == nil)
      [self removeObjectForKey:key];
  }

  return self;
}

@end
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+EMSCore.h"


@implementation NSDictionary (EMSCore)

- (BOOL)subsetOfDictionary:(NSDictionary *)dictionary {
    BOOL result = NO;
    for (id key in [dictionary allKeys]) {
        if ([[self allKeys] containsObject:key] && [self[key] isEqual:dictionary[key]]) {
            result = YES;
        }
    }
    return result;
}

@end
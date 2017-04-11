//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+EMSCore.h"


@implementation NSDictionary (EMSCore)

- (BOOL)subsetOfDictionary:(NSDictionary *)dictionary {
    BOOL result = NO;

    NSArray *dictKeys = [dictionary allKeys];

    if (!dictionary) {
        result = NO;
    } else if ([dictKeys count] == 0) {
        result = YES;
    } else {
        for (id key in dictKeys) {
            if ([[self allKeys] containsObject:key] && [self[key] isEqual:dictionary[key]]) {
                result = YES;
            }
        }
    }

    return result;
}

@end
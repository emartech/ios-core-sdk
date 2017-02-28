//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "RequestModelBuilder.h"

@implementation RequestModelBuilder

- (id)init {
    if (self = [super init]) {
        _requestId = [[NSUUID UUID] UUIDString];
        _timestamp = [NSDate date];
    }
    return self;
}

@end
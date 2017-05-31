//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSInMemoryQueue.h"


@implementation EMSInMemoryQueue {
    NSMutableArray  *_data;
}

- (id)init{
    self = [super init];

    if(self) {
        _data = [NSMutableArray new];
    }

    return self;
}

- (void)push:(EMSRequestModel *)model {
    [_data addObject:model];
}

- (EMSRequestModel *)pop {
    EMSRequestModel *firstModel = [_data firstObject];
    [_data removeObject:firstModel];
    return firstModel;
}

- (EMSRequestModel *)peek {
    return [_data firstObject];
}

- (BOOL)isEmpty {
    return [_data count] == 0;;
}

@end
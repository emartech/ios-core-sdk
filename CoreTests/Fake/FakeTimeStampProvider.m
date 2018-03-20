//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeTimeStampProvider.h"

@implementation FakeTimeStampProvider {
    NSUInteger _timestampIndex;
}

- (instancetype)initWithTimestamps:(NSArray<NSDate *> *)timestamps {
    self = [super init];
    if (self) {
        self.timestamps = timestamps;
    }

    return self;
}

+ (instancetype)providerWithTimestamps:(NSArray<NSDate *> *)timestamps {
    return [[self alloc] initWithTimestamps:timestamps];
}

- (NSDate *)provideTimestamp {
    NSDate *timestamp = self.timestamps[_timestampIndex];
    _timestampIndex++;
    return timestamp;
}

@end
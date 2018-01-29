//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSTimestampProvider.h"


@implementation EMSTimestampProvider

- (NSNumber *)currentTimeStamp {
    return [self timeStampOfDate:[NSDate date]];
}

- (NSNumber *)timeStampOfDate:(NSDate *)date {
    return @((NSUInteger) (1000 * [date timeIntervalSince1970]));;
}

@end
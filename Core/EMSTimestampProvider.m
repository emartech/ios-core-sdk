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

+ (NSString *)utcFormattedStringFromDate:(NSDate *)date {
    return [[EMSTimestampProvider utcDateFormatter] stringFromDate:date];
}

+ (NSString *)currentTimestampInUTC {
    return [EMSTimestampProvider utcFormattedStringFromDate:[NSDate date]];
}

+ (NSDateFormatter *)utcDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    });

    return dateFormatter;
}

@end
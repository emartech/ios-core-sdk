//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EMSTimestampProvider : NSObject

- (NSDate *)provideTimestamp;

- (NSNumber *)currentTimeStamp;

- (NSNumber *)timeStampOfDate:(NSDate *)date;

- (NSString *)currentTimestampInUTC;

- (NSTimeInterval)timeIntervalSince1970;

+ (NSString *)utcFormattedStringFromDate:(NSDate *)date;

+ (NSString *)currentTimestampInUTC;

@end
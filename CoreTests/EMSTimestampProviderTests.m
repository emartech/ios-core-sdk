#import "Kiwi.h"
#import "EMSTimestampProvider.h"


SPEC_BEGIN(EMSTimestampProviderTests)

    describe(@"TimeStampProvider.currentTimestamp", ^{

        __block EMSTimestampProvider *provider;

        beforeEach(^{
            provider = [EMSTimestampProvider new];
        });

        it(@"should not return nil", ^{
            [[[provider currentTimeStamp] shouldNot] beNil];
        });

        it(@"should return the current time", ^{
            NSNumber *before = @((NSUInteger) (1000 * [[NSDate date] timeIntervalSince1970]));
            NSNumber *result = [provider currentTimeStamp];
            NSNumber *after = @((NSUInteger) (1000 * [[NSDate date] timeIntervalSince1970]));

            [[result should] beBetween:before and:after];
        });

        it(@"should return the current timestamp format", ^{
            NSDate *date = [NSDate date];

            [[[provider timeStampOfDate:date] should] equal:@((NSUInteger) (1000 * [date timeIntervalSince1970]))];
        });

        it(@"should return the corrent timestamp format if it has fractions", ^{
            [[[provider timeStampOfDate:[NSDate dateWithTimeIntervalSince1970:12345.5]] should] equal:theValue(12345500)];
        });

    });

    describe(@"TimestampProvider:utcFormattedStringFromDate", ^{

        it(@"should return with the correct formatted dateString", ^{
            NSString *expected = @"2017-12-07T10:46:09.100Z";

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            NSDate *date = [dateFormatter dateFromString:expected];

            [[[EMSTimestampProvider utcFormattedStringFromDate:date] should] equal:expected];
        });

        it(@"should fdsa", ^{
            [EMSTimestampProvider currentTimestampInUTC];
            [EMSTimestampProvider currentTimestampInUTC];
            [EMSTimestampProvider currentTimestampInUTC];
        });

    });

        describe(@"TimestampProvider:timeIntervalSince1970", ^{

            it(@"should return the current timeInterval", ^{
                NSTimeInterval before = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval timeInterval = [EMSTimestampProvider timeIntervalSince1970];
                NSTimeInterval after = [[NSDate date] timeIntervalSince1970];
                [[theValue(timeInterval) should] beBetween:theValue(before) and:theValue(after)];
            });

        });

SPEC_END
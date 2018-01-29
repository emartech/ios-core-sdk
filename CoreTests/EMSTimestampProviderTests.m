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

SPEC_END
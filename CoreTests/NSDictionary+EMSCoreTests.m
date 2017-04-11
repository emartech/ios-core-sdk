//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "NSError+EMSCore.h"
#import "NSDictionary+EMSCore.h"

SPEC_BEGIN(NSDictionaryCoreTests)

    describe(@"NSDictionary+EMSCore subsetOfDictionary:(NSDictionary *)dictionary", ^{
        NSDictionary *testDictionary = @{
                @"key1": @{
                        @"key2": @"value2",
                        @"key3": @"345678",
                        @"key4": @[@456, @"sf"],
                        @"key5": @{
                                @"subKey1": @"subValue1",
                                @"subKey2": @"subValue2",
                                @"subKey3": [NSError errorWithCode:1555
                                              localizedDescription:@"1555"],
                                @12345: @"subValue4"
                        },
                        @"key6": [NSError errorWithCode:1444
                                   localizedDescription:@"1444"],
                        @"key7": [NSNull null]
                },
                @"key8": @23456,
                @"key9": @"value111"
        };

        it(@"should return NO if other dictionary is nil", ^{
            [[@([testDictionary subsetOfDictionary:nil]) should] equal:@(NO)];
        });

        it(@"should return YES if the two dictionary are equal", ^{
            [[@([testDictionary subsetOfDictionary:testDictionary]) should] equal:@(YES)];
        });

        it(@"should return NO if the other dictionary is empty", ^{
            [[@([testDictionary subsetOfDictionary:@{}]) should] equal:@(NO)];
        });

        it(@"should return YES if the other (flat) dictionary is a subset of the dictionary", ^{
            NSDictionary *other = @{
                    @"key8": @23456,
                    @"key9": @"value111"
            };

            [[@([other subsetOfDictionary:testDictionary]) should] equal:@(YES)];
        });
    });

SPEC_END
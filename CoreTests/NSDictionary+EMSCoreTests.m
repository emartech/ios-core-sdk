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

        it(@"should return YES if the other dictionary is isEmpty", ^{
            [[@([testDictionary subsetOfDictionary:@{}]) should] equal:@(YES)];
        });

        it(@"should return YES if the other (flat) dictionary is a subset of the dictionary", ^{
            NSDictionary *other = @{
                    @"key8": @23456,
                    @"key9": @"value111"
            };

            [[@([other subsetOfDictionary:testDictionary]) should] equal:@(YES)];
        });
    });

    describe(@"NSDictionary+EMSCore archive - dictionaryWithData", ^{

        it(@"should return with original values of dictionary after archive and dictionaryWithData", ^{
            NSDictionary *testDict = @{
                    @"key1": @"value1",
                    @"key2": @"value2"
            };

            NSData *data = [testDict archive];
            NSDictionary *returnedDict = [NSDictionary dictionaryWithData:data];

            [[testDict should] equal:returnedDict];
        });
    });

SPEC_END
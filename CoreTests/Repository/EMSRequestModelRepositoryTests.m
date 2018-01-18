//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSRequestModelRepository.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSQueueProtocol.h"
#import "EMSRequestModelFilterSelectFirstSpecification.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(EMSRequestModelRepositoryTests)

    __block EMSSQLiteHelper *helper;
    __block id <EMSRequestModelRepositoryProtocol> repository;

    beforeEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                   error:nil];
        helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
        [helper open];
        repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
    });

    afterEach(^{
        [helper close];
    });


    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    id (^requestModelWithTTL)(NSString *url, NSTimeInterval ttl) = ^id(NSString *url, NSTimeInterval ttl) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodGET];
            [builder setExpiry:ttl];
        }];
    };

    describe(@"query", ^{
        it(@"should return empty array when the table is isEmpty", ^{
            NSArray<EMSRequestModel *> *result = [repository query:[EMSRequestModelFilterSelectFirstSpecification new]];
            [[result should] beEmpty];
        });
    });

    describe(@"add", ^{
        it(@"should not accept nil", ^{
            @try {
                [repository add:nil];
                fail(@"Expected Exception when model is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should insert the requestModel to the repository", ^{
            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", @{@"key1": @"value1"});
            [repository add:expectedModel];
            NSArray<EMSRequestModel *> *result = [repository query:[EMSRequestModelFilterSelectFirstSpecification new]];
            [[result.firstObject should] equal:expectedModel];
        });
    });

    describe(@"delete", ^{
        it(@"should delete the model from the table", ^{
            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", @{@"key1": @"value1"});
            [repository add:expectedModel];
            [repository remove:[EMSRequestModelFilterSelectFirstSpecification new]];
            NSArray<EMSRequestModel *> *result = [repository query:[EMSRequestModelFilterSelectFirstSpecification new]];
            [[result should] beEmpty];
        });
    });


    describe(@"EMSRequestModelFirstSelectSpecification", ^{

        it(@"should keep the order of the elements", ^{
            EMSRequestModel *firstModel = requestModelWithTTL(@"https://url2.com", 58);
            EMSRequestModel *secondModel = requestModelWithTTL(@"https://url2.com", 57);
            
            [repository add:firstModel];
            [repository add:secondModel];

            EMSRequestModel *result1 = [repository query:[EMSRequestModelFilterSelectFirstSpecification new]].firstObject;
            [repository remove:[EMSRequestModelFilterSelectFirstSpecification new]];
            EMSRequestModel *result2 = [repository query:[EMSRequestModelFilterSelectFirstSpecification new]].firstObject;
            [repository remove:[EMSRequestModelFilterSelectFirstSpecification new]];

            [[result1 should] equal:firstModel];
            [[result2 should] equal:secondModel];
        });
    });


SPEC_END
//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"
#import "EMSRequestModelRepository.h"


#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(CoreTest)

    __block EMSSQLiteHelper *helper;
    __block EMSRequestModelRepository *repository;


    describe(@"EMSRequestManager", ^{

        beforeEach(^{
            helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                    schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
            [helper open];
            [helper executeCommand:SQL_PURGE];
            repository = [[EMSRequestModelRepository alloc] initWithDbHelper:helper];
        });

        afterEach(^{
            [helper close];
            [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                       error:nil];
        });

        it(@"should do networking with the gained EMSRequestModel and return success", ^{
            NSString *url = @"https://www.google.com";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                checkableRequestId = requestId;
            }                                                         errorBlock:^(NSString *requestId, NSError *error) {
                NSLog(@"ERROR: %@", error);
                fail([NSString stringWithFormat:@"errorBlock: %@", error]);
            }                                                  requestRepository:repository logRepository:nil];

            [core submit:model];

            [[checkableRequestId shouldEventually] equal:model.requestId];
        });

        it(@"should do networking with the gained EMSRequestModel and return failure", ^{
            NSString *url = @"https://alma.korte.szilva/egyeb/palinkagyumolcsok";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;
            __block NSError *checkableError;

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                fail([NSString stringWithFormat:@"SuccessBlock: %@", response]);
            }                                                         errorBlock:^(NSString *requestId, NSError *error) {
                checkableRequestId = requestId;
                checkableError = error;
            }                                                  requestRepository:repository logRepository:nil];
            [core submit:model];

            [[checkableRequestId shouldEventually] equal:model.requestId];
            [[checkableError shouldNotEventually] beNil];
        });

        it(@"should throw an exception, when model is nil", ^{
            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {

            } errorBlock:^(NSString *requestId, NSError *error) {

            } requestRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]] logRepository:nil];

            @try {
                [core submit:nil];
                fail(@"Expected exception when model is nil");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END

//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModel.h"
#import "EMSSQLiteHelper.h"
#import "EMSSQLiteQueue.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"
#import "EMSRequestManager+Private.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "EMSRESTClient.h"
#import "EMSInMemoryQueue.h"
#import "FakeCompletionHandler.h"
#import "FakeConnectionWatchdog.h"

SPEC_BEGIN(OfflineTests)

    id (^requestManager)(id <EMSQueueProtocol> queue, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) = ^id(id <EMSQueueProtocol> queue, EMSConnectionWatchdog *watchdog, CoreSuccessBlock successBlock, CoreErrorBlock errorBlock) {
        id <EMSWorkerProtocol> worker = [[EMSDefaultWorker alloc] initWithQueue:queue
                                                             connectionWatchdog:watchdog
                                                                     restClient:[EMSRESTClient clientWithSuccessBlock:successBlock
                                                                                                           errorBlock:errorBlock]];
        return [[EMSRequestManager alloc] initWithWorker:worker
                                                   queue:queue];
    };

    beforeEach(^{
        EMSSQLiteHelper *helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                                 schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
        [helper open];
        [helper executeCommand:SQL_PURGE];
        [helper close];
    });

    describe(@"EMSRequestManager", ^{

        it(@"should receive 3 response, when 3 request has been sent", ^{
            EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.google.com"];
                [builder setMethod:HTTPMethodGET];
            }];
            EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.yahoo.com"];
                [builder setMethod:HTTPMethodGET];
            }];
            EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.wolframalpha.com"];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId1;
            __block NSString *checkableRequestId2;
            __block NSString *checkableRequestId3;

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        if (!checkableRequestId1) {
                            checkableRequestId1 = requestId;
                        } else if (!checkableRequestId2) {
                            checkableRequestId2 = requestId;
                        } else {
                            checkableRequestId3 = requestId;
                        }
                    }
                                                                      errorBlock:^(NSString *requestId, NSError *error) {
                                                                          fail([NSString stringWithFormat:@"errorBlock: %@", error]);
                                                                      }];
            [core submit:model1];
            [core submit:model2];
            [core submit:model3];

            [[expectFutureValue(checkableRequestId3) shouldEventuallyBeforeTimingOutAfter(30)] equal:model3.requestId];
            [[expectFutureValue(checkableRequestId2) shouldEventuallyBeforeTimingOutAfter(30)] equal:model2.requestId];
            [[expectFutureValue(checkableRequestId1) shouldEventuallyBeforeTimingOutAfter(30)] equal:model1.requestId];
        });

        it(@"should receive 0 response, queue count 3 when 3 request sent and there is no internet connection", ^{
            EMSRequestModel *model1 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.google.com"];
                [builder setMethod:HTTPMethodGET];
            }];
            EMSRequestModel *model2 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.yahoo.com"];
                [builder setMethod:HTTPMethodGET];
            }];
            EMSRequestModel *model3 = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.wolframalpha.com"];
                [builder setMethod:HTTPMethodGET];
            }];

            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            FakeConnectionWatchdog *watchdog = [[FakeConnectionWatchdog alloc] initWithConnectionResponses:@[@NO, @NO, @NO]];
            FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
            EMSRequestManager *manager = requestManager(queue, watchdog, completionHandler.successBlock, completionHandler.errorBlock);

            [manager submit:model1];
            [manager submit:model2];
            [manager submit:model3];

            [[expectFutureValue(watchdog.isConnectedCallCount) shouldEventually] equal:@3];
            [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@0];
            [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@0];
            [[expectFutureValue(theValue(queue.count)) shouldEventually] equal:theValue(3)];
        });
    });

SPEC_END

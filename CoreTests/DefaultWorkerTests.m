//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "EMSDefaultWorker+Private.h"
#import "TestUtils.h"
#import "EMSInMemoryQueue.h"
#import "EMSSQLiteQueue.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRESTClient.h"
#import "FakeCompletionHandler.h"

SPEC_BEGIN(DefaultWorkerTests)

    void (^successBlock)(NSString *, EMSResponseModel *)=^(NSString *requestId, EMSResponseModel *response) {
    };
    void (^errorBlock)(NSString *, NSError *)=^(NSString *requestId, NSError *error) {
    };


    describe(@"init", ^{

        id (^createWorker)() = ^id() {
            return [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                        connectionWatchdog:[EMSConnectionWatchdog new]
                                                restClient:[EMSRESTClient new]];
        };

        it(@"should not return nil", ^{
            [[createWorker() shouldNot] beNil];
        });

        itShouldThrowException(@"should throw exception, when queue is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:nil
                                       successBlock:successBlock
                                         errorBlock:errorBlock];
        });


        itShouldThrowException(@"should throw exception, when watchdog is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                 connectionWatchdog:nil
                                         restClient:[EMSRESTClient new]];
        });


        itShouldThrowException(@"should throw exception, when restClient is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                 connectionWatchdog:[EMSConnectionWatchdog new]
                                         restClient:nil];
        });

        it(@"should initialize worker as unlocked", ^{
            EMSDefaultWorker *worker = createWorker();

            [[theValue([worker isLocked]) should] beNo];
        });

    });

    describe(@"run", ^{

        id (^requestModel)(NSString *url, NSDictionary *payload, BOOL expired) = ^id(NSString *url, NSDictionary *payload, BOOL expired) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
                if (expired) {
                    [builder setExpiry:-1];
                }
            }];
        };

        beforeEach(^{
        });

        it(@"should lock", ^{
            EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
            [watchdog stub:@selector(isConnected)
                 andReturn:theValue(YES)];
            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            [queue push:requestModel(@"https://url1.com", nil, NO)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queue
                                                            connectionWatchdog:watchdog
                                                                    restClient:[EMSRESTClient new]];
            [worker unlock];
            [worker run];

            [[theValue([worker isLocked]) should] beYes];
            [[theValue([worker isLocked]) should] beYes];
        });

        it(@"should not invoke isConnected on connectionWatchdog, when locked", ^{
            EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
            [mockWatchdog stub:@selector(setConnectionChangeListener:)];
            [[mockWatchdog shouldNot] receive:@selector(isConnected)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:mockWatchdog
                                                                    restClient:[EMSRESTClient new]];
            [worker lock];
            [worker run];
        });

        it(@"should invoke isConnected on connectionWatchdog, when not locked", ^{
            EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
            [mockWatchdog stub:@selector(setConnectionChangeListener:)];
            [[mockWatchdog should] receive:@selector(isConnected)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:mockWatchdog
                                                                    restClient:[EMSRESTClient new]];
            [worker run];
        });

        it(@"should invoke peek on queue, when its running", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            EMSRESTClient *restClient = [EMSRESTClient new];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];
            [restClient stub:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                    restClient:restClient];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            [[worker should] receive:@selector(nextNonExpiredModel)];
            [worker run];
        });

        it(@"should invoke executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete: on Restclient, when its running", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            EMSRESTClient *clientMock = [EMSRESTClient mock];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                    restClient:clientMock];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

            [[worker should] receive:@selector(nextNonExpiredModel)
                           andReturn:expectedModel];
            KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                           atIndex:0];
            [worker run];

            EMSRequestModel *capturedModel = requestSpy.argument;
            [[expectedModel should] equal:capturedModel];
        });

        it(@"should unlock after onComplete called with false", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            EMSRESTClient *clientMock = [EMSRESTClient mock];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                    restClient:clientMock];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

            [[worker should] receive:@selector(nextNonExpiredModel)
                           andReturn:expectedModel];
            KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                              atIndex:1];
            [worker run];

            EMSRestClientCompletionBlock capturedBlock = completionSpy.argument;

            capturedBlock(false);

            [[theValue([worker isLocked]) should] beNo];
        });

        it(@"should unlock and rerun after onComplete called with true", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            EMSRESTClient *clientMock = [EMSRESTClient mock];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                    restClient:clientMock];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil, NO);

            [[worker should] receive:@selector(nextNonExpiredModel)
                           andReturn:expectedModel];
            KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                              atIndex:1];
            [worker run];

            EMSRestClientCompletionBlock capturedBlock = completionSpy.argument;

            [[queueMock should] receive:@selector(pop)];

            capturedBlock(true);

            [[worker shouldEventually] receive:@selector(run)];

            [[theValue([worker isLocked]) should] beNo];

        });

        it(@"should pop expired requestModels", ^{
            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            EMSRequestModel *expectedModel = requestModel(@"https://url123.com", nil, NO);
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:expectedModel];

            EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
            [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
            [watchDog stub:@selector(setConnectionChangeListener:)];

            EMSRESTClient *clientMock = [EMSRESTClient mock];

            FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queue
                                                                  successBlock:completionHandler.successBlock
                                                                    errorBlock:completionHandler.errorBlock];
            [worker setConnectionWatchdog:watchDog];
            [worker setClient:clientMock];

            KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:)
                                                           atIndex:0];
            [worker run];

            EMSRequestModel *model = requestSpy.argument;
            [[model.requestId should] equal:expectedModel.requestId];
            [[theValue([queue count]) should] equal:theValue(1)];
            EMSRequestModel *poppedModel = [queue pop];
            [[poppedModel.requestId should] equal:expectedModel.requestId];
            [[theValue([queue isEmpty]) should] beYes];
        });

        it(@"should report as error when request is expired", ^{
            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            EMSRequestModel *expectedModel = requestModel(@"https://url123.com", nil, NO);
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:expectedModel];

            EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
            [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
            [watchDog stub:@selector(setConnectionChangeListener:)];

            EMSRESTClient *clientMock = [EMSRESTClient mock];
            [[clientMock should] receive:@selector(executeTaskWithOfflineCallbackStrategyWithRequestModel:onComplete:) withArguments:expectedModel, any()];

            FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queue
                                                                  successBlock:completionHandler.successBlock
                                                                    errorBlock:completionHandler.errorBlock];
            [worker setClient:clientMock];

            [worker run];

            [[expectFutureValue(completionHandler.successCount) shouldEventually] equal:@0];
            [[expectFutureValue(completionHandler.errorCount) shouldEventually] equal:@3];
        });

        it(@"should unlock if only expired models were in the queue", ^{
            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];
            [queue push:requestModel(@"https://url1.com", nil, YES)];

            EMSConnectionWatchdog *watchDog = [EMSConnectionWatchdog mock];
            [watchDog stub:@selector(isConnected) andReturn:theValue(YES)];
            [watchDog stub:@selector(setConnectionChangeListener:)];

            FakeCompletionHandler *completionHandler = [FakeCompletionHandler new];
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queue
                                                                  successBlock:completionHandler.successBlock
                                                                    errorBlock:completionHandler.errorBlock];

            [worker run];

            [[theValue([worker isLocked]) should] beNo];
        });
    });


    describe(@"LockableProtocol", ^{

        id (^createWorker)() = ^id() {
            return [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                        connectionWatchdog:[EMSConnectionWatchdog new]
                                                restClient:[EMSRESTClient new]];
        };

        it(@"isLocked should return YES after calling lock", ^{
            EMSDefaultWorker *worker = createWorker();
            [worker unlock];
            [worker lock];
            [[theValue([worker isLocked]) should] beYes];
        });

        it(@"isLocked should return NO after calling unlock", ^{
            EMSDefaultWorker *worker = createWorker();
            [worker lock];
            [worker unlock];
            [[theValue([worker isLocked]) should] beNo];
        });

    });

    describe(@"ConnectionWatchdog", ^{

        it(@"DefaultWorker should implement the connectionChangeListener by default", ^{
            EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:watchdog
                                                                    restClient:[EMSRESTClient new]];
            [[worker should] equal:watchdog.connectionChangeListener];
        });

        it(@"should invoke run, when connectionStatus is connected", ^{
            EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
            [mockWatchdog stub:@selector(setConnectionChangeListener:)];
            [[mockWatchdog should] receive:@selector(isConnected)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:mockWatchdog
                                                                    restClient:[EMSRESTClient new]];
            [worker unlock];
            [worker connectionChangedToNetworkStatus:ReachableViaWiFi
                                    connectionStatus:YES];
        });

    });

SPEC_END

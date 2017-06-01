//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "TestUtils.h"
#import "EMSInMemoryQueue.h"
#import "EMSSQLiteQueue.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRESTClient.h"

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

        id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setPayload:payload];
            }];
        };

        beforeEach(^{
        });

        it(@"should lock", ^{
            EMSConnectionWatchdog *watchdog = [EMSConnectionWatchdog new];
            [watchdog stub:@selector(isConnected)
                 andReturn:theValue(YES)];
            EMSInMemoryQueue *queue = [EMSInMemoryQueue new];
            [queue push:requestModel(@"https://url1.com", nil)];

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
            [restClient stub:@selector(executeTaskWithRequestModel:onComplete:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                    restClient:restClient];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            [[queueMock should] receive:@selector(peek)];
            [worker run];
        });

        it(@"should invoke executeTaskWithRequestModel:onComplete: on Restclient, when its running", ^{
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

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil);

            [[queueMock should] receive:@selector(peek)
                              andReturn:expectedModel];
            KWCaptureSpy *requestSpy = [clientMock captureArgument:@selector(executeTaskWithRequestModel:onComplete:)
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

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil);

            [[queueMock should] receive:@selector(peek)
                              andReturn:expectedModel];
            KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithRequestModel:onComplete:)
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

            EMSRequestModel *expectedModel = requestModel(@"https://url1.com", nil);

            [[queueMock should] receive:@selector(peek)
                              andReturn:expectedModel];
            KWCaptureSpy *completionSpy = [clientMock captureArgument:@selector(executeTaskWithRequestModel:onComplete:)
                                                              atIndex:1];
            [worker run];

            EMSRestClientCompletionBlock capturedBlock = completionSpy.argument;

            capturedBlock(true);

            [[worker shouldEventually] receive:@selector(run)];

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

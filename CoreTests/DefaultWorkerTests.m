//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "TestUtils.h"
#import "EMSInMemoryQueue.h"
#import "EMSConnectionWatchdog.h"
#import "EMSSQLiteQueue.h"
#import "EMSRequestModelBuilder.h"
#import "NSURLRequest+EMSCore.h"

SPEC_BEGIN(DefaultWorkerTests)

    void (^successBlock)(NSString *, EMSResponseModel *)=^(NSString *requestId, EMSResponseModel *response) {
    };
    void (^errorBlock)(NSString *, NSError *)=^(NSString *requestId, NSError *error) {
    };


    describe(@"init", ^{

        id (^createWorker)() = ^id() {
            return [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                        connectionWatchdog:[EMSConnectionWatchdog new]
                                                   session:[NSURLSession sharedSession]
                                              successBlock:successBlock
                                                errorBlock:errorBlock];
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
                                            session:[NSURLSession sharedSession]
                                       successBlock:successBlock
                                         errorBlock:errorBlock];
        });


        itShouldThrowException(@"should throw exception, when session is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                 connectionWatchdog:[EMSConnectionWatchdog new]
                                            session:nil
                                       successBlock:successBlock
                                         errorBlock:errorBlock];
        });

        itShouldThrowException(@"should throw exception, when successBlock is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                 connectionWatchdog:[EMSConnectionWatchdog new]
                                            session:[NSURLSession sharedSession]
                                       successBlock:nil
                                         errorBlock:errorBlock];
        });

        itShouldThrowException(@"should throw exception, when errorBlock is nil", ^{
            [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                 connectionWatchdog:[EMSConnectionWatchdog new]
                                            session:[NSURLSession sharedSession]
                                       successBlock:successBlock
                                         errorBlock:nil];
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
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
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
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
            [worker lock];
            [worker run];
        });

        it(@"should invoke isConnected on connectionWatchdog, when not locked", ^{
            EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
            [mockWatchdog stub:@selector(setConnectionChangeListener:)];
            [[mockWatchdog should] receive:@selector(isConnected)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:mockWatchdog
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
            [worker run];
        });

        it(@"should invoke peek on queue, when its running", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            NSURLSession *sessionMock = [NSURLSession mock];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                       session:sessionMock
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];

            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            [[queueMock should] receive:@selector(peek)
                              andReturn:requestModel(@"https://url1.com", nil)];
            [[sessionMock should] receive:@selector(dataTaskWithRequest:completionHandler:)];

            [worker run];
        });

        it(@"should invoke dataTaskWithRequest on session, when its running", ^{
            EMSSQLiteQueue *queueMock = [EMSSQLiteQueue mock];
            EMSConnectionWatchdog *watchdogMock = [EMSConnectionWatchdog mock];
            NSURLSession *sessionMock = [NSURLSession mock];

            [watchdogMock stub:@selector(setConnectionChangeListener:)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:queueMock
                                                            connectionWatchdog:watchdogMock
                                                                       session:sessionMock
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
            [[watchdogMock should] receive:@selector(isConnected)
                                 andReturn:theValue(YES)];
            [[queueMock should] receive:@selector(isEmpty)
                              andReturn:theValue(NO)];

            EMSRequestModel *model = requestModel(@"https://url1.com", nil);

            [[queueMock should] receive:@selector(peek)
                              andReturn:model];

            NSURLSessionDataTask *taskMock = [NSURLSessionDataTask mock];

            [[sessionMock should] receive:@selector(dataTaskWithRequest:completionHandler:)
                                andReturn:taskMock];
            [[taskMock should] receive:@selector(resume)];
            KWCaptureSpy *requestSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                            atIndex:0];
            KWCaptureSpy *completionHandlerSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                                      atIndex:1];
            [worker run];

            NSURLRequest *expectedRequest = [NSURLRequest requestWithRequestModel:model];
            NSURLRequest *request = requestSpy.argument;

            void (^completionHandler)(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) = completionHandlerSpy.argument;

            [[expectedRequest should] equal:request];
            [[completionHandler shouldNot] beNil];
        });

    });

    describe(@"LockableProtocol", ^{

        id (^createWorker)() = ^id() {
            return [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                        connectionWatchdog:[EMSConnectionWatchdog new]
                                                   session:[NSURLSession sharedSession]
                                              successBlock:successBlock
                                                errorBlock:errorBlock];
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
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
            [[worker should] equal:watchdog.connectionChangeListener];
        });

        it(@"should invoke run, when connectionStatus is connected", ^{
            EMSConnectionWatchdog *mockWatchdog = [EMSConnectionWatchdog mock];
            [mockWatchdog stub:@selector(setConnectionChangeListener:)];
            [[mockWatchdog should] receive:@selector(isConnected)];

            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:mockWatchdog
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
            [worker unlock];
            [worker connectionChangedToNetworkStatus:ReachableViaWiFi
                                    connectionStatus:YES];
        });

    });

SPEC_END

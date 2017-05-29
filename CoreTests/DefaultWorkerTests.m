//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "TestUtils.h"
#import "EMSInMemoryQueue.h"
#import "EMSConnectionWatchdog.h"


SPEC_BEGIN(DefaultWorkerTests)

    void (^successBlock)(NSString *, EMSResponseModel *)=^(NSString *requestId, EMSResponseModel *response) {
    };
    void (^errorBlock)(NSString *, NSError *)=^(NSString *requestId, NSError *error) {
    };

    id (^createWorker)() = ^id() {
        EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                        connectionWatchdog:[EMSConnectionWatchdog new]
                                                                   session:[NSURLSession sharedSession]
                                                              successBlock:successBlock
                                                                errorBlock:errorBlock];
        return worker;
    };

    beforeEach(^{

    });

    describe(@"init", ^{

        it(@"should not return nil", ^{
            [[createWorker() shouldNot] beNil];
        });

        itShouldThrowException(@"should throw exception, when queue is nil", ^{
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:nil
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
        });


        itShouldThrowException(@"should throw exception, when watchdog is nil", ^{
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:nil
                                                                       session:[NSURLSession sharedSession]
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
        });


        itShouldThrowException(@"should throw exception, when session is nil", ^{
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:[EMSInMemoryQueue new]
                                                            connectionWatchdog:[EMSConnectionWatchdog new]
                                                                       session:nil
                                                                  successBlock:successBlock
                                                                    errorBlock:errorBlock];
        });


        it(@"should initialize worker as unlocked", ^{
            EMSDefaultWorker *worker = createWorker();

            [[theValue([worker isLocked]) should] beNo];
        });

    });

    describe(@"run", ^{

        it(@"should lock", ^{
            EMSDefaultWorker *worker = createWorker();
            [worker run];

            [[theValue([worker isLocked]) should] beYes];
            [[theValue([worker isLocked]) should] beYes];
        });

    });




SPEC_END

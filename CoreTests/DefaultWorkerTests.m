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

    beforeEach(^{

    });

    describe(@"init", ^{

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

    });

SPEC_END

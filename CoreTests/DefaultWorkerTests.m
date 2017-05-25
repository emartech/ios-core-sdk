//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDefaultWorker.h"
#import "TestUtils.h"

SPEC_BEGIN(DefaultWorkerTests)



    beforeEach(^{

    });

    describe(@"init", ^{

        xitShouldThrowException(@"should throw exception, when queue is nil", ^{
            EMSDefaultWorker *worker = [[EMSDefaultWorker alloc] initWithQueue:nil
                                                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {}
                                                                    errorBlock:^(NSString *requestId, NSError *error) {}];
        });

    });

SPEC_END

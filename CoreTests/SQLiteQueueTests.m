//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSQueueProtocol.h"
#import "EMSSQLiteQueue.h"
#import "EMSRequestModelBuilder.h"

SPEC_BEGIN(SQLiteQueueTests)

    beforeEach(^{

    });

    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    id (^createQueue)() = ^id <EMSQueueProtocol>() {
        return [EMSSQLiteQueue new];
    };

    describe(@"push", ^{

        it(@"should store item in the queue", ^{

        });

    });


SPEC_END
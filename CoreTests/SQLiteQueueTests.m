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

    describe(@"pop", ^{
        it(@"should return nil when the queue is empty", ^{
            EMSSQLiteQueue *queue = createQueue();

            [[[queue pop] should] beNil];
        });
    });

    describe(@"push", ^{

        xit(@"should throw exception when the model is nil", ^{
            id <EMSQueueProtocol> queue = createQueue();
            @try {
                [queue push:nil];
                fail(@"Expected Exception when model is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });


SPEC_END
//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "Core.h"
#import "RequestModelBuilder.h"
#import "RequestModel.h"

SPEC_BEGIN(CoreTest)

    describe(@"Core", ^{

        it(@"should do networking with the gained RequestModel and return success", ^{
            NSString *url = @"http://www.google.com";

            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;

            Core *core = [Core new];
            [core submit:model
            successBlock:^(NSString *requestId) {
                checkableRequestId = requestId;
            } errorBlock:nil];

            [[expectFutureValue(checkableRequestId) shouldEventually] equal:model.requestId];
        });

        it(@"should do networking with the gained RequestModel and return failure", ^{
            NSString *url = @"http://alma.korte.szilva/egyeb/palinkagyumolcsok";

            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;
            __block NSError *checkableError;

            Core *core = [Core new];
            [core submit:model
            successBlock:nil
              errorBlock:^(NSString *requestId, NSError *error) {
                  checkableRequestId = requestId;
                  checkableError = error;
              }];

            [[expectFutureValue(checkableRequestId) shouldEventually] equal:model.requestId];
            [[expectFutureValue(checkableError) shouldNotEventually] beNil];
        });

        it(@"should throw an exception, when model is nil", ^{
            RequestModel *model;
            Core *core = [Core new];

            @try {
                [core submit:model
                successBlock:nil
                  errorBlock:nil];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                NSLog(@"%@", exception);
            }
        });

    });

SPEC_END

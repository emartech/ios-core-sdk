//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModel.h"

SPEC_BEGIN(CoreTest)

    describe(@"EMSRequestManager", ^{

        it(@"should do networking with the gained EMSRequestModel and return success", ^{
            NSString *url = @"http://www.google.com";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;

            EMSRequestManager *core = [EMSRequestManager new];
            [core submit:model
            successBlock:^(NSString *requestId) {
                checkableRequestId = requestId;
            } errorBlock:nil];

            [[expectFutureValue(checkableRequestId) shouldEventually] equal:model.requestId];
        });

        it(@"should do networking with the gained EMSRequestModel and return failure", ^{
            NSString *url = @"http://alma.korte.szilva/egyeb/palinkagyumolcsok";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;
            __block NSError *checkableError;

            EMSRequestManager *core = [EMSRequestManager new];
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
            EMSRequestModel *model;
            EMSRequestManager *core = [EMSRequestManager new];

            @try {
                [core submit:model
                successBlock:nil
                  errorBlock:nil];
                fail(@"Expected exception when model is nil");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END

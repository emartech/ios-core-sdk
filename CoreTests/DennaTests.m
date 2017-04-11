//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestManager.h"
#import "EMSResponseModel.h"
#import "NSDictionary+EMSCore.h"

#define DennaUrl(ending) [NSString stringWithFormat:@"https://ems-denna.herokuapp.com%@", ending];

SPEC_BEGIN(DennaTest)

    NSString *error500 = DennaUrl(@"/error500");
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *inputHeaders = @{@"Header1": @"value1", @"Header2": @"value2"};
    NSDictionary *payload = @{@"key1": @"val1", @"key2": @"val2", @"key3": @"val3"};

    void (^shouldEventuallySucceed)(EMSRequestModel *model, NSString *method, NSDictionary<NSString *, NSString *> *headers, NSDictionary<NSString *, id> *body) = ^(EMSRequestModel *model, NSString *method, NSDictionary<NSString *, NSString *> *headers, NSDictionary<NSString *, id> *body) {
        __block NSString *checkableRequestId;
        __block NSString *resultMethod;
        __block BOOL expectedSubsetOfResultHeaders;
        __block NSDictionary<NSString *, id> *resultPayload;

        EMSRequestManager *core = [EMSRequestManager new];
        [core submit:model
        successBlock:^(NSString *requestId, EMSResponseModel *response) {
            checkableRequestId = requestId;
            NSDictionary<NSString *, id> *returnedPayload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:nil];
            NSLog(@"RequestId: %@, responsePayload: %@", requestId, returnedPayload);
            resultMethod = returnedPayload[@"method"];
            expectedSubsetOfResultHeaders = [returnedPayload[@"headers"] subsetOfDictionary:headers];
            resultPayload = returnedPayload[@"body"];
        }
          errorBlock:^(NSString *_Nonnull requestId, NSError *_Nonnull error) {
              NSLog(@"ERROR!");
              fail(@"errorblock invoked");
          }];

        [[expectFutureValue(resultMethod) shouldEventually] equal:method];
        [[expectFutureValue(@(expectedSubsetOfResultHeaders)) shouldEventually] equal:@YES];
        if (body) {
            [[expectFutureValue(resultPayload) shouldEventually] equal:body];
        }
        [[expectFutureValue(model.requestId) shouldEventually] equal:checkableRequestId];
    };


    describe(@"EMSRequestManager", ^{
        it(@"should invoke errorBlock when calling error500 on Denna", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:error500];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;

            EMSRequestManager *core = [EMSRequestManager new];
            [core submit:model
            successBlock:^(NSString *requestId, EMSResponseModel *response) {
                NSLog(@"ERROR!");
                fail(@"successBlock invoked :'(");
            }
              errorBlock:^(NSString *_Nonnull requestId, NSError *_Nonnull error) {
                  checkableRequestId = requestId;
              }];
            [[expectFutureValue(checkableRequestId) shouldEventually] equal:model.requestId];
        });

        it(@"should respond with the GET request's headers/body", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:echo];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:inputHeaders];
            }];
            shouldEventuallySucceed(model, @"GET", inputHeaders, nil);
        });

        it(@"should respond with the POST request's headers/body", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:echo];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:inputHeaders];
                [builder setPayload:payload];
            }];
            shouldEventuallySucceed(model, @"POST", inputHeaders, payload);
        });
    });

SPEC_END

//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestManager.h"
#import "EMSResponseModel.h"

#define DennaUrl(ending) [NSString stringWithFormat:@"http://appledev-server.ett.local:8900%@", ending];

SPEC_BEGIN(DennaTest)

    NSString *error500 = DennaUrl(@"/error500");
    NSString *echo = DennaUrl(@"/echo");
    NSDictionary *headers = @{@"header1": @"value1", @"header2": @"value2"};
    NSDictionary *payload = @{@"key1": @"val1", @"key2": @"val2", @"key3": @"val3"};

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

        xit(@"should respond with the GET request's headers/body", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:echo];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:headers];
                [builder setPayload:payload];
            }];

            __block NSString *checkableRequestId;
            __block NSDictionary<NSString *, id> *resultPayload;

            EMSRequestManager *core = [EMSRequestManager new];
            [core submit:model
            successBlock:^(NSString *requestId, EMSResponseModel *response) {
                checkableRequestId = requestId;
                resultPayload = [NSJSONSerialization JSONObjectWithData:response.body
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
            }
              errorBlock:^(NSString *_Nonnull requestId, NSError *_Nonnull error) {
                  NSLog(@"ERROR!");
                  fail(@"errorblock invoked :'(");
              }];

            NSDictionary *expectedPayload = @{
                    @"method": @"GET",
                    @"headers": headers,
                    @"payload": payload
            };
            [[expectFutureValue(resultPayload) shouldEventually] equal:expectedPayload];
            [[expectFutureValue(model.requestId) shouldEventually] equal:checkableRequestId];
        });
    });

SPEC_END

//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"Builder", ^{

        it(@"should create a model with requestId and timestamp", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.timestamp shouldNot] beNil];
            [[model.requestId shouldNot] beNil];
        });

        it(@"should create a model where default requestMethod is POST", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"POST"];
        });

        it(@"should create a model with specified requestMethod when setMethod is called on builder", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"GET"];
        });

        it(@"should create a model with specified requestUrl when setUrl is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSURL *url = [NSURL URLWithString:urlString];
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:urlString];
            }];

            [[model.url shouldNot] beNil];
            [[model.url should] equal:url];
        });

        it(@"should create a model with specified ttl when setExpiry is called on the builder", ^{
           EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
               [builder setUrl:@"http://www.google.com"];
               [builder setExpiry:3];
           }];

            [[theValue(model.ttl) should] equal:theValue(3)];
        });

        it(@"should create a model with specified body when setBody is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSDictionary *payload = @{@"key": @"value"};
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setPayload:payload];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.payload should] equal:payload];
        });

        it(@"should create a model with specified headers when setHeaders is called on builder", ^{
            NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2"
            };
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setHeaders:headers];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.headers should] equal:headers];
        });

        it(@"should throw an exception, when builderBlock is nil", ^{
            @try {
                [EMSRequestModel makeWithBuilder:nil];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw an exception, when requestUrl is invalid", ^{
            @try {
                [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"fatal"];
                }];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw an exception, when requestUrl is nil", ^{
            @try {
                [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                }];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END

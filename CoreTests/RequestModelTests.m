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

        it(@"should create a model where default method is POST", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"POST"];
        });

        it(@"should create a model with specified method when setMethod is called on builder", ^{
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"GET"];
        });

        it(@"should create a model with specified url when setUrl is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSURL *url = [NSURL URLWithString:urlString];
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:urlString];
            }];

            [[model.url shouldNot] beNil];
            [[model.url should] equal:url];
        });

        it(@"should create a model with specified body when setBody is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setBody:data];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.body should] equal:data];
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

        it(@"should throw an exception, when url is invalid", ^{
            @try {
                [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:@"fatal"];
                }];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw an exception, when url is nil", ^{
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

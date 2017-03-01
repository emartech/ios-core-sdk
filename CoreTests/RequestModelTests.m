//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "RequestModel.h"
#import "RequestModelBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"Builder", ^{

        it(@"should create a model with requestId and timestamp", ^{
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.timestamp shouldNot] beNil];
            [[model.requestId shouldNot] beNil];
        });

        it(@"should create a model where default method is POST", ^{
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"POST"];
        });

        it(@"should create a model with specified method when setMethod is called on builder", ^{
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.method should] equal:@"GET"];
        });

        it(@"should create a model with specified url when setUrl is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSURL *url = [NSURL URLWithString:urlString];
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:urlString];
            }];

            [[model.url shouldNot] beNil];
            [[model.url should] equal:url];
        });

        it(@"should create a model with specified body when setBody is called on builder", ^{
            NSString *urlString = @"http://www.google.com";
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
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
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setHeaders:headers];
                [builder setUrl:@"http://www.google.com"];
            }];

            [[model.headers should] equal:headers];
        });

        it(@"should throw an exception, when builderBlock is nil", ^{
            @try {
                [RequestModel makeWithBuilder:nil];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw an exception, when url is invalid", ^{
            @try {
                [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                    [builder setUrl:@"fatal"];
                }];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw an exception, when url is nil", ^{
            @try {
                [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                }];
                fail(@"Assertation doesn't called!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END

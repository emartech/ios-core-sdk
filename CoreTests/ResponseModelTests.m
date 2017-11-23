//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSResponseModel.h"

SPEC_BEGIN(ResponseModelTests)

    describe(@"ResponseModel init", ^{

        it(@"should be created and fill all of properties, when correct NSHttpUrlResponse and NSData is passed", ^{
            NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2"
            };
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"host.com/url"]
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:headers];
            NSString *dataString = @"dataString";
            NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:response
                                                                                           data:data];
            NSString *responseDataString = [[NSString alloc] initWithData:responseModel.body
                                                                 encoding:NSUTF8StringEncoding];
            [[@(responseModel.statusCode) should] equal:@200];
            [[responseModel.headers should] equal:headers];
            [[responseDataString should] equal:dataString];
        });



        it(@"should create ResponseModel with the specified properties", ^{
            NSData *responseBody = [NSJSONSerialization dataWithJSONObject:@{@"b1": @"bv1"} options:0 error:nil];
            EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402 headers:@{@"h1": @"hv1"} body:responseBody];

            [[theValue(model.statusCode) should] equal:theValue(402)];
            [[model.headers[@"h1"] should] equal:@"hv1"];

            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:model.body options:0 error:nil];
            [[json[@"b1"] should] equal:@"bv1"];
        });

    });

    describe(@"parsedBody", ^{

        it(@"should return the body parsed as JSON", ^{
            NSDictionary *dict = @{@"b1": @"bv1", @"deep": @{@"child1": @"value1"}};
            NSData *responseBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402 headers:@{} body:responseBody];

            [[model.parsedBody should] equal:dict];
        });

        it(@"should return nil when body is nil", ^{
            EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402 headers:@{} body:nil];

            [[model.parsedBody should] beNil];
        });

        it(@"should return nil when body is not a JSON", ^{
            EMSResponseModel *model = [[EMSResponseModel alloc] initWithStatusCode:402 headers:@{} body:[@"Created" dataUsingEncoding:NSUTF8StringEncoding]];

            [[model.parsedBody should] beNil];
        });

    });

SPEC_END
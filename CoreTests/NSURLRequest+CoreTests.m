//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "RequestModel.h"
#import "RequestModelBuilder.h"
#import "NSURLRequest+Core.h"

SPEC_BEGIN(NSURLRequestCoreTests)

    describe(@"NSURLRequest+CoreTests requestWithRequestModel:(RequestModel *)model", ^{

        it(@"should create an NSUrlRequest from RequestModel", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *headers = @{@"asdasd" : @"dgereg"};
            NSData *body = [@"fdahsjk" dataUsingEncoding:NSUTF8StringEncoding];

            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:headers];
                [builder setBody:body];
            }];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[request allHTTPHeaderFields] should] equal:headers];
            [[[request HTTPBody] should] equal:body];
        });

    });

SPEC_END

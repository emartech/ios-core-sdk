//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "NSURLRequest+EMSCore.h"

SPEC_BEGIN(NSURLRequestCoreTests)

    describe(@"NSURLRequest+CoreTests requestWithRequestModel:(EMSRequestModel *)model", ^{

        it(@"should create an NSUrlRequest from EMSRequestModel", ^{

            NSString *url = @"http://www.google.com";
            NSDictionary *headers = @{@"asdasd" : @"dgereg"};
            NSData *body = [@"fdahsjk" dataUsingEncoding:NSUTF8StringEncoding];

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
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

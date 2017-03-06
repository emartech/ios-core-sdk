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
            NSDictionary *payload = @{@"key": @"value"};

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodPOST];
                [builder setHeaders:headers];
                [builder setPayload:payload];
            }];

            NSURLRequest *request = [NSURLRequest requestWithRequestModel:model];

            NSError *error = nil;
            NSData *body = [NSJSONSerialization dataWithJSONObject:payload
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

            [[[[request URL] absoluteString] should] equal:url];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] should] equal:headers];
            [[[request HTTPBody] should] equal:body];
        });

    });

SPEC_END

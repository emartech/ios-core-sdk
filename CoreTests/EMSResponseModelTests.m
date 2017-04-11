//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSResponseModel.h"

SPEC_BEGIN(ResponseModelTests)

    describe(@"ResponseModel", ^{

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

    });

SPEC_END
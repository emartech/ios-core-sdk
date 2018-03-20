//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSResponseModel.h"
#import "EMSTimestampProvider.h"

@implementation EMSResponseModel {
    id _parsedBody;
}

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data
            timestampProvider:(EMSTimestampProvider *)timestampProvider {
    return [self initWithStatusCode:httpUrlResponse.statusCode
                            headers:httpUrlResponse.allHeaderFields
                               body:data
                  timestampProvider:timestampProvider];
}

- (id)initWithStatusCode:(NSInteger)statusCode
                 headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body
       timestampProvider:(EMSTimestampProvider *)timestampProvider {
    if (self = [super init]) {
        _statusCode = statusCode;
        _headers = headers;
        _body = body;
        _timestamp = [timestampProvider provideTimestamp];
    }
    return self;
}

- (id)parsedBody {
    if (!_parsedBody && _body) {
        _parsedBody = [NSJSONSerialization JSONObjectWithData:_body options:0 error:nil];
    }
    return _parsedBody;
}

@end

//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSResponseModel.h"

@implementation EMSResponseModel

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data {
    if (self = [super init]) {
        _statusCode = httpUrlResponse.statusCode;
        _headers = httpUrlResponse.allHeaderFields;
        _body = data;
    }
    return self;
}

- (id)initWithStatusCode:(NSInteger)statusCode headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body {
    if (self = [super init]) {
        _statusCode = statusCode;
        _headers = headers;
        _body = body;
    }
    return self;
}

- (id)parsedBody {
    return _body ? [NSJSONSerialization JSONObjectWithData:_body options:0 error:nil] : nil;
}


@end

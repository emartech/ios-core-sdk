//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelBuilder.h"

@implementation EMSRequestModelBuilder

- (id)init {
    if (self = [super init]) {
        _requestId = [[NSUUID UUID] UUIDString];
        _timestamp = [NSDate date];
        _method = @"POST";
    }
    return self;
}

- (EMSRequestModelBuilder *)setMethod:(HTTPMethod)method {
    switch (method) {
        case HTTPMethodPOST:
            _method = @"POST";
            break;
        case HTTPMethodGET:
            _method = @"GET";
            break;
    }
    return self;
}

- (EMSRequestModelBuilder *)setUrl:(NSString *)url {
    NSURL *urlToCheck = [NSURL URLWithString:url];
    if (urlToCheck && urlToCheck.scheme && urlToCheck.host) {
        _url = urlToCheck;
    }
    return self;
}

- (EMSRequestModelBuilder *)setBody:(NSData *)body {
    _body = body;
    return self;
}

- (EMSRequestModelBuilder *)setHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    _headers = headers;
    return self;
}

@end
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


@end

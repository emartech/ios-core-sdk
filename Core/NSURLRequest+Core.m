//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSURLRequest+Core.h"
#import "RequestModel.h"


@implementation NSURLRequest (Core)

+ (NSURLRequest *)requestWithRequestModel:(RequestModel *)requestModel {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestModel.url];
    [request setHTTPMethod:requestModel.method];
    [request setAllHTTPHeaderFields:requestModel.headers];
    [request setHTTPBody:requestModel.body];
    return request;
}

@end
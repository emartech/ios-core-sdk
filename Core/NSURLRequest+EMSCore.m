//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSURLRequest+EMSCore.h"
#import "EMSRequestModel.h"


@implementation NSURLRequest (EMSCore)

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestModel.url];
    [request setHTTPMethod:requestModel.method];
    [request setAllHTTPHeaderFields:requestModel.headers];
    [request setHTTPBody:requestModel.body];
    return request;
}

@end
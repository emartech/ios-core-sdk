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

    if ([requestModel.method isEqualToString:@"POST"] && requestModel.payload) {
        NSError *error;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestModel.payload
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&error]];
        if (error) {
            request = nil;
        }
    }
    NSAssert(request, @"Cannot create NSURLRequest from RequestModel");
    return request;
}

@end
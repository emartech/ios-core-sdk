//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestModel;

@interface NSURLRequest (Core)

+ (NSURLRequest *)requestWithRequestModel:(RequestModel *)requestModel;

@end
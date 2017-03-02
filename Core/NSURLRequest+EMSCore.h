//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModel;

@interface NSURLRequest (EMSCore)

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel;

@end
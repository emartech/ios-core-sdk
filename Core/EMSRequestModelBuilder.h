//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HTTPMethodPOST,
    HTTPMethodGET
} HTTPMethod;

@interface EMSRequestModelBuilder : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *payload;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

- (EMSRequestModelBuilder *)setMethod:(HTTPMethod)method;
- (EMSRequestModelBuilder *)setUrl:(NSString *)url;
- (EMSRequestModelBuilder *)setPayload:(NSDictionary<NSString *, id> *)payload;
- (EMSRequestModelBuilder *)setHeaders:(NSDictionary<NSString *, NSString *> *)headers;

@end
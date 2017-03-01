//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HTTPMethodPOST,
    HTTPMethodGET
} HTTPMethod;

@interface RequestModelBuilder : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSData *body;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

- (RequestModelBuilder *)setMethod:(HTTPMethod)method;
- (RequestModelBuilder *)setUrl:(NSString *)url;
- (RequestModelBuilder *)setBody:(NSData *)body;
- (RequestModelBuilder *)setHeaders:(NSDictionary<NSString *, NSString *> *)headers;

@end
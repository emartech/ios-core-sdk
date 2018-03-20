//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

@interface EMSResponseModel : NSObject

@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly) NSData *body;
@property(nonatomic, readonly) NSDate *timestamp;

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data
            timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (id)initWithStatusCode:(NSInteger)statusCod
                 headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body
       timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (id)parsedBody;

@end

NS_ASSUME_NONNULL_END

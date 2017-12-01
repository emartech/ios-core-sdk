//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSResponseModel : NSObject

@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly) NSData *body;

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data;

- (id)initWithStatusCode:(NSInteger)statusCode
                 headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body;

- (id)parsedBody;

@end

NS_ASSUME_NONNULL_END

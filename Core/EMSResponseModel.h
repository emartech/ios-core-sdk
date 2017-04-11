//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSResponseModel : NSObject

@property(nonatomic, assign, readonly) NSInteger statusCode;
@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly) NSData *body;

- (id)initWithHttpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse
                         data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
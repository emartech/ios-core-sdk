//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModelBuilder;

@interface EMSRequestModel : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSData *body;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

typedef void(^BuilderBlock)(EMSRequestModelBuilder * _Nonnull builder);

+ (nonnull EMSRequestModel *)makeWithBuilder:(BuilderBlock)builderBlock;

@end
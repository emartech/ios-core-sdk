//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestModelBuilder;

@interface RequestModel : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

typedef void(^BuilderBlock)(RequestModelBuilder* _Nonnull builder);

+ (nonnull RequestModel *)makeWithBuilder:(BuilderBlock)builderBlock;

@end
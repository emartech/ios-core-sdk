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
@property (nonatomic, readonly) NSDictionary<NSString *, id> *payload;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

typedef void(^EMSRequestBuilderBlock)(EMSRequestModelBuilder * _Nonnull builder);

+ (nonnull EMSRequestModel *)makeWithBuilder:(EMSRequestBuilderBlock)builderBlock;

- (BOOL)isEqualToModel:(EMSRequestModel *)model;

@end
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModelBuilder;

NS_ASSUME_NONNULL_BEGIN
@interface EMSRequestModel : NSObject

@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *payload;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

typedef void(^EMSRequestBuilderBlock)(EMSRequestModelBuilder *builder);

+ (EMSRequestModel *)makeWithBuilder:(EMSRequestBuilderBlock)builderBlock;

- (BOOL)isEqualToModel:(EMSRequestModel *)model;

@end

NS_ASSUME_NONNULL_END
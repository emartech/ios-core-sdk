//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class EMSResponseModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CoreErrorBlock)(NSString *requestId, NSError *error);

typedef void (^CoreSuccessBlock)(NSString *requestId, EMSResponseModel *response);

@interface EMSRequestManager : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *additionalHeaders;

- (void)submit:(EMSRequestModel *)model
  successBlock:(nullable CoreSuccessBlock)successBlock
    errorBlock:(nullable CoreErrorBlock)errorBlock;


@end

NS_ASSUME_NONNULL_END
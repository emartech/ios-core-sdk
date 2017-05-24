//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@class EMSRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestManager : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *additionalHeaders;

- (void)submit:(EMSRequestModel *)model
  successBlock:(nullable CoreSuccessBlock)successBlock
    errorBlock:(nullable CoreErrorBlock)errorBlock;


@end

NS_ASSUME_NONNULL_END
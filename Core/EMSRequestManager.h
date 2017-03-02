//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModel;

typedef void (^CoreErrorBlock)(NSString *requestId, NSError *error);
typedef void (^CoreSuccessBlock)(NSString *requestId);

@interface EMSRequestManager : NSObject

- (void)setAdditionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders;

- (void)submit:(EMSRequestModel *)model
  successBlock:(CoreSuccessBlock)successBlock
    errorBlock:(CoreErrorBlock)errorBlock;


@end

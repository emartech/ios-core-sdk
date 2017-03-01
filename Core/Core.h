//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestModel;

typedef void (^CoreErrorBlock)(NSString *requestId, NSError *error);
typedef void (^CoreSuccessBlock)(NSString *requestId);

@interface Core : NSObject

- (void)submit:(RequestModel *)model
  successBlock:(CoreSuccessBlock)successBlock
    errorBlock:(CoreErrorBlock)errorBlock;

@end

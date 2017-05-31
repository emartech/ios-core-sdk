//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSCoreCompletionHandlerMiddleware : NSObject

@property(nonatomic, strong, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, strong, readonly) CoreErrorBlock errorBlock;
@property(nonatomic, strong, readonly) void (^completionBlock)(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error);

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock;

@end

NS_ASSUME_NONNULL_END
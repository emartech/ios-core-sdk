//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSRestClientCompletionBlock)(BOOL shouldContinue);
typedef void (^EMSRestClientOnSuccessBlock)(NSData *responseData);
typedef void (^EMSRestClientOnErrorBlock)(NSError *error);

@interface EMSRESTClient : NSObject

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock;

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                                  session:(NSURLSession *)session;


- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                          onSuccess:(EMSRestClientOnSuccessBlock)onSuccess
                            onError:(EMSRestClientOnErrorBlock)onError;

- (void)executeTaskWithOfflineCallbackStrategyWithRequestModel:(EMSRequestModel *)requestModel
                                                    onComplete:(EMSRestClientCompletionBlock)onComplete;


@end

NS_ASSUME_NONNULL_END
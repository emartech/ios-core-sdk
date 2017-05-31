//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSWorkerProtocol.h"
#import "EMSCoreCompletion.h"
#import "EMSConnectionWatchdog.h"

@protocol EMSQueueProtocol;
@class EMSConnectionWatchdog;

NS_ASSUME_NONNULL_BEGIN

@interface EMSDefaultWorker : NSObject <EMSWorkerProtocol, EMSConnectionChangeListener>

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock;

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                      session:(NSURLSession *)session
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock;
@end

NS_ASSUME_NONNULL_END
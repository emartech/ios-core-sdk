//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSWorkerProtocol.h"
#import "EMSCoreCompletion.h"
#import "EMSConnectionWatchdog.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSLogRepositoryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSDefaultWorker : NSObject <EMSWorkerProtocol, EMSConnectionChangeListener>

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock
                   requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                       logRepository:(id <EMSLogRepositoryProtocol>)logRepository;
@end

NS_ASSUME_NONNULL_END
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSConnectionWatchdog.h"

@interface EMSDefaultWorker ()

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    return nil;
}

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                      session:(NSURLSession *)session
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    return nil;
}

#pragma mark - WorkerProtocol

- (void)run {

}

#pragma mark - LockableProtocol

- (void)lock {

}

- (void)unlock {

}

- (BOOL)locked {
    return NO;
}

@end
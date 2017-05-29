//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSConnectionWatchdog.h"

@interface EMSDefaultWorker ()
@property (nonatomic, assign) BOOL locked;
@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    return [self initWithQueue:queue connectionWatchdog:[EMSConnectionWatchdog new] session:[NSURLSession sharedSession] successBlock:successBlock errorBlock:errorBlock];
}

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                      session:(NSURLSession *)session
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    self = [super init];
    if (self) {
        NSParameterAssert(queue);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(session);
    }
    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    [self lock];
    [self execute];
}

- (void)execute {
    NSLog(@"original execute");
}

#pragma mark - LockableProtocol

- (void)lock {
    self.locked = YES;
}

- (void)unlock {

}

- (BOOL)isLocked {
    return self.locked;
}

@end
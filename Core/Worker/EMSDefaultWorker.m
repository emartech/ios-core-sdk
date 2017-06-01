//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSRequestModel.h"
#import "EMSRESTClient.h"
#import "EMSQueueProtocol.h"
#import "NSURLRequest+EMSCore.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSQueueProtocol> queue;
@property(nonatomic, strong) EMSRESTClient *client;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    return [self initWithQueue:queue
            connectionWatchdog:[EMSConnectionWatchdog new]
                    restClient:[EMSRESTClient clientWithSuccessBlock:successBlock
                                                          errorBlock:errorBlock]];
}

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                   restClient:(EMSRESTClient *)client {
    if (self = [super init]) {
        NSParameterAssert(queue);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(client);

        _connectionWatchdog = connectionWatchdog;
        [_connectionWatchdog setConnectionChangeListener:self];
        _queue = queue;
        _client = client;
    }
    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    if (![self isLocked] && [self.connectionWatchdog isConnected] && ![self.queue isEmpty]) {
        [self lock];
        EMSRequestModel *model = [self.queue peek];
        [self.client executeTaskWithRequestModel:model
                                      onComplete:^(BOOL shouldContinue) {
                                          //TODO: do not forget it please!
                                      }];
    }
}

#pragma mark - LockableProtocol

- (void)lock {
    _locked = YES;
}

- (void)unlock {
    _locked = NO;
}

- (BOOL)isLocked {
    return _locked;
}

#pragma mark - EMSConnectionChangeListener

- (void)connectionChangedToNetworkStatus:(NetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected {
    if (connected) {
        [self run];
    }
}


@end
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSRequestModel.h"
#import "EMSRESTClient.h"
#import "EMSQueueProtocol.h"
#import "NSError+EMSCore.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSQueueProtocol> queue;
@property(nonatomic, strong) EMSRESTClient *client;
@property(nonatomic, strong) CoreErrorBlock errorBlock;

- (EMSRequestModel *)nextNonExpiredModel;

- (BOOL)isExpired:(EMSRequestModel *)model;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    _errorBlock = errorBlock;
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
        EMSRequestModel *model = [self nextNonExpiredModel];
        __weak typeof(self) weakSelf = self;
        if (model) {
            [self.client executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                     onComplete:^(BOOL shouldContinue) {
                                                                         [weakSelf unlock];
                                                                         if (shouldContinue) {
                                                                             [weakSelf.queue pop];
                                                                             [[NSOperationQueue currentQueue] addOperationWithBlock:^{
                                                                                 [weakSelf run];
                                                                             }];
                                                                         }
                                                                     }];
        } else {
            [self unlock];
        }
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

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected {
    if (connected) {
        [self run];
    }
}

#pragma mark - Private methods

- (EMSRequestModel *)nextNonExpiredModel {
    while (![self.queue isEmpty] && [self isExpired:[self.queue peek]]) {
        self.errorBlock([self.queue pop].requestId, [NSError errorWithCode:408
                                                      localizedDescription:@"Request expired"]);
    }
    return [self.queue peek];
}

- (BOOL)isExpired:(EMSRequestModel *)model {
    return [[NSDate date] timeIntervalSince1970] - [[model timestamp] timeIntervalSince1970] > [model ttl];
}

@end
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSRESTClient.h"
#import "NSError+EMSCore.h"
#import "EMSRequestModelSelectFirstSpecification.h"
#import "EMSRequestModelDeleteByIdsSpecification.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> repository;
@property(nonatomic, strong) EMSRESTClient *client;
@property(nonatomic, strong) CoreErrorBlock errorBlock;

- (EMSRequestModel *)nextNonExpiredModel;

- (BOOL)isExpired:(EMSRequestModel *)model;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                             successBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    _errorBlock = errorBlock;
    return [self initWithRequestRepository:repository
                        connectionWatchdog:[EMSConnectionWatchdog new]
                                restClient:[EMSRESTClient clientWithSuccessBlock:successBlock
                                                                      errorBlock:errorBlock]];
}

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                       connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                               restClient:(EMSRESTClient *)client {
    if (self = [super init]) {
        NSParameterAssert(repository);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(client);

        _connectionWatchdog = connectionWatchdog;
        [_connectionWatchdog setConnectionChangeListener:self];
        _repository = repository;
        _client = client;
    }

    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    if (![self isLocked] && [self.connectionWatchdog isConnected] && ![self.repository isEmpty]) {
        [self lock];
        EMSRequestModel *model = [self nextNonExpiredModel];
        __weak typeof(self) weakSelf = self;
        if (model) {
            [self.client executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                     onComplete:^(BOOL shouldContinue) {
                                                                         [weakSelf unlock];
                                                                         if (shouldContinue) {
                                                                             [weakSelf.repository remove:[[EMSRequestModelDeleteByIdsSpecification alloc] initWithRequestModel:model]];
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
    EMSRequestModel *model;
    while ((model = [self.repository query:[EMSRequestModelSelectFirstSpecification new]].firstObject) && [self isExpired:model]) {
        [self.repository remove:[[EMSRequestModelDeleteByIdsSpecification alloc] initWithRequestModel:model]];
        self.errorBlock(model.requestId, [NSError errorWithCode:408
                                                      localizedDescription:@"Request expired"]);
    }
    return model;
}

- (BOOL)isExpired:(EMSRequestModel *)model {
    return [[NSDate date] timeIntervalSince1970] - [[model timestamp] timeIntervalSince1970] > [model ttl];
}

@end
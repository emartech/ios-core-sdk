//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "EMSRequestModel.h"
#import "EMSCoreCompletionHandlerMiddleware.h"
#import "EMSQueueProtocol.h"
#import "NSURLRequest+EMSCore.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSQueueProtocol> queue;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    return [self initWithQueue:queue
            connectionWatchdog:[EMSConnectionWatchdog new]
                       session:[NSURLSession sharedSession]
                  successBlock:successBlock
                    errorBlock:errorBlock];
}

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                      session:(NSURLSession *)session
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    if (self = [super init]) {
        NSParameterAssert(queue);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(session);
        NSParameterAssert(successBlock);
        NSParameterAssert(errorBlock);
        _connectionWatchdog = connectionWatchdog;
        [_connectionWatchdog setConnectionChangeListener:self];
        _queue = queue;
        _session = session;
        _successBlock = successBlock;
        _errorBlock = errorBlock;
    }
    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    if (![self isLocked] && [self.connectionWatchdog isConnected] && ![self.queue isEmpty]) {
        [self lock];
        EMSRequestModel *model = [self.queue peek];
        NSURLRequest *request = [NSURLRequest requestWithRequestModel:model];
        EMSCoreCompletionHandlerMiddleware *middleware = [[EMSCoreCompletionHandlerMiddleware alloc] initWithSuccessBlock:self.successBlock
                                                                                                               errorBlock:self.errorBlock];
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                         completionHandler:middleware.completionBlock];
        [dataTask resume];
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
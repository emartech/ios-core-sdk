//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSResponseModel.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

typedef void (^RunnerBlock)(void);

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSWorkerProtocol> worker;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager {
    NSOperationQueue *_coreQueue;
}

#pragma mark - Init

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock
                      requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                          logRepository:(id <EMSLogRepositoryProtocol>)logRepository {
    return [[EMSRequestManager alloc] initWithWorker:[[EMSDefaultWorker alloc] initWithSuccessBlock:successBlock
                                                                                         errorBlock:errorBlock
                                                                                  requestRepository:requestRepository
                                                                                      logRepository:logRepository]
                                   requestRepository:requestRepository];
}

- (instancetype)initWithWorker:(id <EMSWorkerProtocol>)worker
             requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository {
    if (self = [super init]) {
        _repository = repository;
        _worker = worker;
    }
    return self;
}


#pragma mark - Public methods

- (void)submit:(EMSRequestModel *)model {
    NSParameterAssert(model);
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", model]];

    __weak typeof(self) weakSelf = self;
    [self runInCoreQueueWithBlock:^{
        EMSRequestModel *requestModel = model;
        if (weakSelf.additionalHeaders) {
            NSMutableDictionary *headers;
            if (model.headers) {
                headers = [NSMutableDictionary dictionaryWithDictionary:model.headers];
                [headers addEntriesFromDictionary:weakSelf.additionalHeaders];
            } else {
                headers = [NSMutableDictionary dictionaryWithDictionary:weakSelf.additionalHeaders];
            }
            requestModel = [[EMSRequestModel alloc] initWithRequestId:model.requestId
                                                            timestamp:model.timestamp
                                                               expiry:model.ttl
                                                                  url:model.url
                                                               method:model.method
                                                              payload:model.payload
                                                              headers:[NSDictionary dictionaryWithDictionary:headers]
                                                               extras:[NSDictionary dictionaryWithDictionary:model.extras]];
        }
        [weakSelf.repository add:requestModel];
        [weakSelf.worker run];
    }];
}

- (void)setAdditionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders {
    [EMSLogger logWithTopic:EMSCoreTopic.networkingTopic
                    message:[NSString stringWithFormat:@"Argument: %@", additionalHeaders]];
    _additionalHeaders = additionalHeaders;
}


#pragma mark - Private methods

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock {
    if (!_coreQueue) {
        _coreQueue = [NSOperationQueue new];
        _coreQueue.maxConcurrentOperationCount = 1;
        _coreQueue.qualityOfService = NSQualityOfServiceUtility;
    }

    [_coreQueue addOperationWithBlock:runnerBlock];
}

@end

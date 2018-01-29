//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSResponseModel.h"
#import "EMSWorkerProtocol.h"
#import "EMSDefaultWorker.h"
#import "EMSRequestModelRepository.h"
#import "EMSSqliteQueueSchemaHandler.h"

typedef void (^RunnerBlock)();

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> repository;
@property(nonatomic, strong) id <EMSWorkerProtocol> worker;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager {
    NSOperationQueue *_coreQueue;
}

#pragma mark - Init

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock {
    EMSRequestModelRepository *repository = [[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                                                                                               schemaDelegate:[EMSSqliteQueueSchemaHandler new]]];
    return [EMSRequestManager managerWithSuccessBlock:successBlock errorBlock:errorBlock requestRepository:repository];
}

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock
                      requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository {
    return [[EMSRequestManager alloc] initWithWorker:[[EMSDefaultWorker alloc] initWithRequestRepository:repository
                                                                                            successBlock:successBlock
                                                                                              errorBlock:errorBlock]
                                   requestRepository:repository];
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
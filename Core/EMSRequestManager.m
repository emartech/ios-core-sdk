//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "EMSSQLiteQueue.h"
#import "EMSWorkerProtocol.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSDefaultWorker.h"

typedef void (^RunnerBlock)();

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSQueueProtocol> queue;
@property(nonatomic, strong) id <EMSWorkerProtocol> worker;

- (instancetype)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                          errorBlock:(nullable CoreErrorBlock)errorBlock;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager {
    NSOperationQueue *_coreQueue;
}

#pragma mark - Init

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock {
    return [[EMSRequestManager alloc] initWithSuccessBlock:successBlock
                                                errorBlock:errorBlock];
}

- (instancetype)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                          errorBlock:(nullable CoreErrorBlock)errorBlock {
    id <EMSQueueProtocol> queue = [[EMSSQLiteQueue alloc] initWithSQLiteHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                                                                              schemaDelegate:[EMSSqliteQueueSchemaHandler new]]];
    return [self initWithWorker:[[EMSDefaultWorker alloc] initWithQueue:queue
                                                           successBlock:successBlock
                                                             errorBlock:errorBlock]
                          queue:queue];
}

- (instancetype)initWithWorker:(id <EMSWorkerProtocol>)worker
                         queue:(id <EMSQueueProtocol>)queue {
    if (self = [super init]) {
        _queue = queue;
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
                                                               expiry:model.expiry
                                                                  url:model.url
                                                               method:model.method
                                                              payload:model.payload
                                                              headers:[NSDictionary dictionaryWithDictionary:headers]];
        }
        [weakSelf.queue push:requestModel];
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
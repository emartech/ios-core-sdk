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

- (id)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                errorBlock:(nullable CoreErrorBlock)errorBlock;

- (void)runInCoreQueueWithBlock:(RunnerBlock)runnerBlock;

@end

@implementation EMSRequestManager {
    NSOperationQueue * _coreQueue;
}

#pragma mark - Init

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock {
    return [[EMSRequestManager alloc] initWithSuccessBlock:successBlock
                                                errorBlock:errorBlock];
}

- (id)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                errorBlock:(nullable CoreErrorBlock)errorBlock {
    if (self = [super init]) {
        _queue = [[EMSSQLiteQueue alloc] initWithSQLiteHelper:[[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                                                             schemaDelegate:[EMSSqliteQueueSchemaHandler new]]];
        _worker = [[EMSDefaultWorker alloc] initWithQueue:_queue
                                             successBlock:successBlock
                                               errorBlock:errorBlock];
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
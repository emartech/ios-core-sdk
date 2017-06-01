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

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) id <EMSQueueProtocol> queue;
@property(nonatomic, strong) id <EMSWorkerProtocol> worker;

- (id)initWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                errorBlock:(nullable CoreErrorBlock)errorBlock;

@end

@implementation EMSRequestManager

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
    if (self.additionalHeaders) {
        NSMutableDictionary *headers;
        if (model.headers) {
            headers = [NSMutableDictionary dictionaryWithDictionary:model.headers];
            [headers addEntriesFromDictionary:self.additionalHeaders];
        } else {
            headers = [NSMutableDictionary dictionaryWithDictionary:self.additionalHeaders];
        }
        model = [[EMSRequestModel alloc] initWithRequestId:model.requestId
                                                 timestamp:model.timestamp
                                                       url:model.url
                                                    method:model.method
                                                   payload:model.payload
                                                   headers:[NSDictionary dictionaryWithDictionary:headers]];
    }
    [self.queue push:model];
    [self.worker run];
}

@end
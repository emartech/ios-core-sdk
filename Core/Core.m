//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Core.h"
#import "RequestModel.h"
#import "NSURLRequest+Core.h"

@interface Core() <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation Core

#pragma mark - Init
- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setTimeoutIntervalForRequest:10.0];
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:operationQueue];
    }
    return self;
}

#pragma mark - Public methods
- (void)submit:(RequestModel *)model
  successBlock:(CoreSuccessBlock)successBlock
    errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(model);
    NSURLRequest *request = [NSURLRequest requestWithRequestModel:model];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (errorBlock) {
                errorBlock(model.requestId, error);
            }
        } else if (successBlock) {
            successBlock(model.requestId);
        }
    }];
    [dataTask resume];
}

@end

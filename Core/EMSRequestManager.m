//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSRequestModel.h"
#import "NSURLRequest+EMSCore.h"

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation EMSRequestManager

#pragma mark - Init

- (id)init{
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

- (void)submit:(EMSRequestModel *)model
  successBlock:(CoreSuccessBlock)successBlock
    errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(model);
    NSURLRequest *request = [NSURLRequest requestWithRequestModel:model
                                                additionalHeaders:self.additionalHeaders];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if (error && errorBlock) {
                                                             errorBlock(model.requestId, error);
                                                         }
                                                         if (!error && successBlock) {
                                                             successBlock(model.requestId);
                                                         }
                                                     }];
    [dataTask resume];
}

@end

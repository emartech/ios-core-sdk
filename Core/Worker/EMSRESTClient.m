//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRESTClient.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel.h"

@interface EMSRESTClient () <NSURLSessionDelegate>

@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSURLSession *session;

@end

@implementation EMSRESTClient

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock
                             session:(NSURLSession *)session {
    if (self = [super init]) {
        NSParameterAssert(successBlock);
        NSParameterAssert(errorBlock);
        _successBlock = successBlock;
        _errorBlock = errorBlock;
        if (session) {
            _session = session;
        } else {
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            [sessionConfiguration setTimeoutIntervalForRequest:30.0];
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            [operationQueue setMaxConcurrentOperationCount:1];
            _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:operationQueue];
        }
    }
    return self;
}

+ (EMSRESTClient *)clientWithSession:(NSURLSession *)session {
    return [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {}
                                      errorBlock:^(NSString *requestId, NSError *error) {}
                                         session:session];
}

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock {
    return [EMSRESTClient clientWithSuccessBlock:successBlock
                                      errorBlock:errorBlock
                                         session:nil];
}

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                                  session:(NSURLSession *)session {
    return [[EMSRESTClient alloc] initWithSuccessBlock:successBlock
                                            errorBlock:errorBlock
                                               session:session];
}

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel successBlock:(CoreSuccessBlock)successBlock errorBlock:(CoreErrorBlock)errorBlock {
    NSURLSessionDataTask *task =
            [self.session dataTaskWithRequest:[NSURLRequest requestWithRequestModel:requestModel]
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *) response;
                                NSInteger statusCode = httpUrlResponse.statusCode;
                                const BOOL hasError = error || statusCode < 200 || statusCode > 299;
                                if (errorBlock && hasError) {
                                    errorBlock(requestModel.requestId,
                                            error ? error : [self errorWithData:data statusCode:statusCode]);
                                }
                                if (successBlock && !hasError) {
                                    successBlock(requestModel.requestId, [[EMSResponseModel alloc] initWithHttpUrlResponse:httpUrlResponse
                                                                                                                      data:data]);
                                }
                            }];
    [task resume];
}

- (void)executeTaskWithOfflineCallbackStrategyWithRequestModel:(EMSRequestModel *)requestModel
                                                    onComplete:(EMSRestClientCompletionBlock)onComplete {
    NSParameterAssert(onComplete);
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task =
            [self.session dataTaskWithRequest:[NSURLRequest requestWithRequestModel:requestModel]
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf handleResponse:requestModel
                                                        data:data
                                                    response:response
                                                       error:error
                                                  onComplete:onComplete];
                                });
                            }];
    [task resume];
}

- (void)handleResponse:(EMSRequestModel *)requestModel
                  data:(NSData *)data
              response:(NSURLResponse *)response
                 error:(NSError *)error
            onComplete:(EMSRestClientCompletionBlock)onComplete {
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpUrlResponse.statusCode;
    const BOOL hasError = error || statusCode < 200 || statusCode > 299;
    const BOOL nonRetriableRequest = [self isStatusCodeNonRetriable:statusCode] || [self isErrorNonRetriable:error];

    if (self.errorBlock && nonRetriableRequest) {
        self.errorBlock(requestModel.requestId,
                error ? error : [self errorWithData:data statusCode:statusCode]);
    }

    if (self.successBlock && !hasError) {
        self.successBlock(requestModel.requestId, [[EMSResponseModel alloc] initWithHttpUrlResponse:httpUrlResponse
                                                                                               data:data]);
    }

    if (onComplete) {
        const BOOL shouldContinue = !hasError || nonRetriableRequest;
        onComplete(shouldContinue);
    }
}

- (BOOL)isErrorNonRetriable:(NSError *)error {
    return error.code == NSURLErrorCannotFindHost || error.code == NSURLErrorBadURL || error.code == NSURLErrorUnsupportedURL;
}

- (BOOL)isStatusCodeNonRetriable:(NSInteger)statusCode {
    if (statusCode == 408) return NO;
    return statusCode >= 400 && statusCode < 500;
}

- (NSError *)errorWithData:(NSData *)data
                statusCode:(NSInteger)statusCode {
    NSString *description =
            data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"Unknown error";
    return [NSError errorWithCode:@(statusCode).intValue
             localizedDescription:description];
}

@end


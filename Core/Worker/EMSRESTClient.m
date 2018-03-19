//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRESTClient.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel.h"
#import "EMSCompositeRequestModel.h"

@interface EMSRESTClient () <NSURLSessionDelegate>

@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSURLSession *session;

@end

@implementation EMSRESTClient

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock
                             session:(NSURLSession *)session
                       logRepository:(nullable id <EMSLogRepositoryProtocol>)logRepository {
    if (self = [super init]) {
        NSParameterAssert(successBlock);
        NSParameterAssert(errorBlock);
        _successBlock = successBlock;
        _errorBlock = errorBlock;
        _logRepository = logRepository;
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
    return [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                      }
                                         session:session
                                   logRepository:nil];
}

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                            logRepository:(id <EMSLogRepositoryProtocol>)logRepository {
    return [EMSRESTClient clientWithSuccessBlock:successBlock
                                      errorBlock:errorBlock
                                         session:nil
                                   logRepository:logRepository];
}

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                                  session:(nullable NSURLSession *)session
                            logRepository:(nullable id <EMSLogRepositoryProtocol>)logRepository {
    return [[EMSRESTClient alloc] initWithSuccessBlock:successBlock
                                            errorBlock:errorBlock
                                               session:session
                                         logRepository:logRepository];
}

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                       successBlock:(CoreSuccessBlock)successBlock
                         errorBlock:(CoreErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task =
            [self.session dataTaskWithRequest:[NSURLRequest requestWithRequestModel:requestModel]
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *) response;
                                NSInteger statusCode = httpUrlResponse.statusCode;
                                const BOOL hasError = error || statusCode < 200 || statusCode > 299;
                                if (errorBlock && hasError) {
                                    errorBlock(requestModel.requestId,
                                            error ? error : [weakSelf    errorWithData:data
                                                                         statusCode:statusCode]);
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
    NSTimeInterval networkStartingTimeInterval = [NSDate date].timeIntervalSince1970;
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    NSURLSessionDataTask *task =
            [self.session dataTaskWithRequest:[NSURLRequest requestWithRequestModel:requestModel]
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                [currentQueue addOperationWithBlock:^{
                                    [weakSelf handleResponse:requestModel
                                                        data:data
                                                    response:response
                                                       error:error
                                                  onComplete:onComplete];
                                }];
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
        [self executeErrorBlockWithModel:requestModel
                            responseData:data
                              statusCode:statusCode
                                   error:error];
    }
    if (self.successBlock && !hasError) {
        [self executeSuccessBlockWithModel:requestModel
                              responseData:data
                                  response:httpUrlResponse];
    }
    if (onComplete) {
        const BOOL shouldContinue = !hasError || nonRetriableRequest;
        onComplete(shouldContinue);
    }
}

- (void)executeSuccessBlockWithModel:(EMSRequestModel *)requestModel
                        responseData:(NSData *)data
                            response:(NSHTTPURLResponse *)httpUrlResponse {
    if ([requestModel isKindOfClass:[EMSCompositeRequestModel class]]) {
        NSArray<EMSRequestModel *> *originalRequests = [(EMSCompositeRequestModel *) requestModel originalRequests];
        for (EMSRequestModel *request in originalRequests) {
            self.successBlock(request.requestId, [[EMSResponseModel alloc] initWithHttpUrlResponse:httpUrlResponse
                                                                                              data:data]);
        }
    } else {
        self.successBlock(requestModel.requestId, [[EMSResponseModel alloc] initWithHttpUrlResponse:httpUrlResponse
                                                                                               data:data]);
    }
}

- (void)executeErrorBlockWithModel:(EMSRequestModel *)requestModel responseData:(NSData *)data statusCode:(NSInteger)statusCode error:(NSError *)error {
    if ([requestModel isKindOfClass:[EMSCompositeRequestModel class]]) {
        NSArray<EMSRequestModel *> *originalRequests = [(EMSCompositeRequestModel *) requestModel originalRequests];
        for (EMSRequestModel *request in originalRequests) {
            self.errorBlock(request.requestId,
                    error ? error : [self errorWithData:data statusCode:statusCode]);
        }
    } else {
        self.errorBlock(requestModel.requestId,
                error ? error : [self errorWithData:data statusCode:statusCode]);
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


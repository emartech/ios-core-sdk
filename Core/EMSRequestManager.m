//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestManager.h"
#import "EMSRequestModel.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"

@interface EMSRequestManager () <NSURLSessionDelegate>

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation EMSRequestManager

#pragma mark - Init

- (id)init{
    if (self = [super init]) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setTimeoutIntervalForRequest:30.0];
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
                                                         NSInteger statusCode = ((NSHTTPURLResponse *) response).statusCode;
                                                         if (errorBlock) {
                                                             if (error) {
                                                                 errorBlock(model.requestId, error);
                                                             } else if (statusCode < 200 || statusCode > 299) {
                                                                 NSString *description = @"Unknown error";
                                                                 if (data) {
                                                                     description = [[NSString alloc] initWithData:data
                                                                                                         encoding:NSUTF8StringEncoding];
                                                                 }
                                                                 errorBlock(model.requestId, [NSError errorWithCode:statusCode
                                                                                               localizedDescription:description]);
                                                             }
                                                         }
                                                         if (successBlock && !error && (statusCode >= 200 && statusCode <= 299)) {
                                                             successBlock(model.requestId);
                                                         }
                                                     }];
    [dataTask resume];
}

@end

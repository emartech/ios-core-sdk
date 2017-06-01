//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//


#import "Kiwi.h"
#import "EMSResponseModel.h"
#import "TestUtils.h"
#import "EMSRESTClient.h"
#import "EMSRequestModelBuilder.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"

SPEC_BEGIN(EMSRESTClientTests)

    void (^successBlock)(NSString *, EMSResponseModel *) = ^(NSString *requestId, EMSResponseModel *response) {
    };
    void (^errorBlock)(NSString *, NSError *) = ^(NSString *requestId, NSError *error) {
    };

    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    describe(@"RESTClient", ^{

        itShouldThrowException(@"should throw exception when successBlock is nil", ^{
            [EMSRESTClient clientWithSuccessBlock:nil
                                       errorBlock:errorBlock];
        });

        itShouldThrowException(@"should throw exception when errorBlock is nil", ^{
            [EMSRESTClient clientWithSuccessBlock:successBlock
                                       errorBlock:nil];
        });

        itShouldThrowException(@"should throw exception when completionBlock is nil", ^{
            EMSRESTClient *client = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                               errorBlock:errorBlock];
            [client executeTaskWithRequestModel:requestModel(@"https://url1.com", nil)
                                     onComplete:nil];
        });

        it(@"executeTaskWithRequestModel should call dataTaskWithRequest:completionHandler: with the correct requestModel", ^{
            NSURLSession *sessionMock = [NSURLSession mock];

            EMSRequestModel *model = requestModel(@"https://url1.com", nil);

            EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                                   errorBlock:errorBlock
                                                                      session:sessionMock];
            KWCaptureSpy *sessionSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                            atIndex:0];

            [restClient executeTaskWithRequestModel:model
                                         onComplete:^(BOOL shouldContinue) {

                                         }];

            NSURLRequest *expectedRequest = [NSURLRequest requestWithRequestModel:model];
            NSURLRequest *capturedRequest = sessionSpy.argument;

            [[expectedRequest should] equal:capturedRequest];
        });

        it(@"executeTaskWithRequestModel should execute datatask returned by dataTaskWithRequest:completionHandler:", ^{
            NSURLSession *sessionMock = [NSURLSession mock];

            EMSRequestModel *model = requestModel(@"https://url1.com", nil);

            EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:successBlock
                                                                   errorBlock:errorBlock
                                                                      session:sessionMock];
            NSURLSessionDataTask *dataTaskMock = [NSURLSessionDataTask mock];
            [[sessionMock should] receive:@selector(dataTaskWithRequest:completionHandler:)
                                andReturn:dataTaskMock];
            [[dataTaskMock should] receive:@selector(resume)];

            KWCaptureSpy *sessionSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                            atIndex:0];

            [restClient executeTaskWithRequestModel:model
                                         onComplete:^(BOOL shouldContinue) {

                                         }];

            NSURLRequest *expectedRequest = [NSURLRequest requestWithRequestModel:model];
            NSURLRequest *capturedRequest = sessionSpy.argument;

            [[expectedRequest should] equal:capturedRequest];
        });

        it(@"executeTaskWithRequestModel should return requestId, and responseModel on successBlock, when everything is fine", ^{
            NSURLSession *sessionMock = [NSURLSession mock];

            NSString *urlString = @"https://url1.com";
            EMSRequestModel *model = requestModel(urlString, nil);
            NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                     statusCode:200
                                                                    HTTPVersion:nil
                                                                   headerFields:nil];
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];

            __block NSString *successRequestId;
            __block NSString *errorRequestId;
            __block EMSResponseModel *returnedResponse;
            __block NSError *returnedError;
            __block BOOL returnedShouldContinue;

            KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                          atIndex:1];

            EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        successRequestId = requestId;
                        returnedResponse = response;
                    }
                                                                   errorBlock:^(NSString *requestId, NSError *error) {
                                                                       errorRequestId = requestId;
                                                                       returnedError = error;
                                                                   }
                                                                      session:sessionMock];

            [restClient executeTaskWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                returnedShouldContinue = shouldContinue;
            }];

            void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable error) = blockSpy.argument;

            completionBlock(data, urlResponse, nil);

            [[expectFutureValue(successRequestId) shouldEventually] equal:model.requestId];
            [[expectFutureValue(returnedResponse) shouldNotEventually] beNil];
            [[expectFutureValue(errorRequestId) shouldEventually] beNil];
            [[expectFutureValue(returnedError) shouldEventually] beNil];
            [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beYes];
        });

        it(@"executeTaskWithRequestModel should not return requestId or error on errorBlock nor successId and response when there is a retriable error", ^{
            NSURLSession *sessionMock = [NSURLSession mock];

            NSString *urlString = @"https://url1.com";
            EMSRequestModel *model = requestModel(urlString, nil);
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                     statusCode:500
                                                                    HTTPVersion:nil
                                                                   headerFields:nil];
            NSError *error = [NSError errorWithCode:5000 localizedDescription:@"crazy"];

            __block NSString *successRequestId;
            __block NSString *errorRequestId;
            __block EMSResponseModel *returnedResponse;
            __block NSError *returnedError;
            __block BOOL returnedShouldContinue;

            KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                          atIndex:1];

            EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        successRequestId = requestId;
                        returnedResponse = response;
                    }
                                                                   errorBlock:^(NSString *requestId, NSError *blockError) {
                                                                       errorRequestId = requestId;
                                                                       returnedError = blockError;
                                                                   }
                                                                      session:sessionMock];

            [restClient executeTaskWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                returnedShouldContinue = shouldContinue;
            }];

            void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable completionError) = blockSpy.argument;

            completionBlock(data, urlResponse, error);

            [[expectFutureValue(successRequestId) shouldEventually] beNil];
            [[expectFutureValue(returnedResponse) shouldEventually] beNil];
            [[expectFutureValue(errorRequestId) shouldEventually] beNil];
            [[expectFutureValue(returnedError) shouldEventually] beNil];
            [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beNo];
        });

        it(@"executeTaskWithRequestModel should return requestId, and error on errorBlock, when there is a non-retriable error", ^{
            NSURLSession *sessionMock = [NSURLSession mock];

            NSString *urlString = @"https://url1.com";
            EMSRequestModel *model = requestModel(urlString, nil);
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:urlString]
                                                                     statusCode:404
                                                                    HTTPVersion:nil
                                                                   headerFields:nil];
            NSError *error = [NSError errorWithCode:5000 localizedDescription:@"crazy"];

            __block NSString *successRequestId;
            __block NSString *errorRequestId;
            __block EMSResponseModel *returnedResponse;
            __block NSError *returnedError;
            __block BOOL returnedShouldContinue;

            KWCaptureSpy *blockSpy = [sessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:)
                                                          atIndex:1];

            EMSRESTClient *restClient = [EMSRESTClient clientWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        successRequestId = requestId;
                        returnedResponse = response;
                    }
                                                                   errorBlock:^(NSString *requestId, NSError *blockError) {
                                                                       errorRequestId = requestId;
                                                                       returnedError = blockError;
                                                                   }
                                                                      session:sessionMock];

            [restClient executeTaskWithRequestModel:model onComplete:^(BOOL shouldContinue) {
                returnedShouldContinue = shouldContinue;
            }];

            void (^completionBlock)(NSData *_Nullable completionData, NSURLResponse *_Nullable response, NSError *_Nullable completionError) = blockSpy.argument;

            completionBlock(data, urlResponse, error);

            [[expectFutureValue(successRequestId) shouldEventually] beNil];
            [[expectFutureValue(returnedResponse) shouldEventually] beNil];
            [[expectFutureValue(errorRequestId) shouldEventually] equal:model.requestId];
            [[expectFutureValue(returnedError) shouldEventually] equal:error];
            [[expectFutureValue(theValue(returnedShouldContinue)) shouldEventually] beYes];
        });

    });

SPEC_END
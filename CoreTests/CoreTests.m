//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModel.h"
#import "EMSSQLiteHelper.h"
#import "EMSSQLiteQueue.h"
#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"

SPEC_BEGIN(CoreTest)

    __block EMSSQLiteHelper *helper;

    beforeEach(^{
        helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                                schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
        [helper open];
        [helper executeCommand:SQL_PURGE];
        [helper close];
    });

    afterEach(^{
        [helper close];
    });


    describe(@"EMSRequestManager", ^{

        it(@"should do networking with the gained EMSRequestModel and return success", ^{
            NSString *url = @"https://www.google.com";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        checkableRequestId = requestId;
                    }
                                                                      errorBlock:^(NSString *requestId, NSError *error) {
                                                                          NSLog(@"ERROR: %@", error);
                                                                          fail([NSString stringWithFormat:@"errorBlock: %@", error]);
                                                                      }];

            [core submit:model];

            [[checkableRequestId shouldEventually] equal:model.requestId];
        });

        it(@"should do networking with the gained EMSRequestModel and return failure", ^{
            NSString *url = @"https://alma.korte.szilva/egyeb/palinkagyumolcsok";

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:url];
                [builder setMethod:HTTPMethodGET];
            }];

            __block NSString *checkableRequestId;
            __block NSError *checkableError;

            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                        fail([NSString stringWithFormat:@"SuccessBlock: %@", response]);
                    }
                                                                      errorBlock:^(NSString *requestId, NSError *error) {
                                                                          checkableRequestId = requestId;
                                                                          checkableError = error;
                                                                      }];
            [core submit:model];

            [[checkableRequestId shouldEventually] equal:model.requestId];
            [[checkableError shouldNotEventually] beNil];
        });

        it(@"should throw an exception, when model is nil", ^{
            EMSRequestManager *core = [EMSRequestManager managerWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
                    }
                                                                      errorBlock:^(NSString *requestId, NSError *error) {

                                                                      }];
            @try {
                [core submit:nil];
                fail(@"Expected exception when model is nil");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END

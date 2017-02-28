//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "RequestModel.h"
#import "RequestModelBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"Builder", ^{

        it(@"should create a model with requestId and timestamp", ^{
            RequestModel *model = [RequestModel makeWithBuilder:^(RequestModelBuilder *builder) {
            }];

            [[model.timestamp shouldNot] beNil];
            [[model.requestId shouldNot] beNil];
        });

    });

SPEC_END

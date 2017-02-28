//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "RequestModel.h"
#import "RequestModelBuilder.h"

@implementation RequestModel

+ (nonnull RequestModel *)makeWithBuilder:(BuilderBlock)builderBlock {
    RequestModelBuilder *builder = [RequestModelBuilder new];

    return [[RequestModel alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(RequestModelBuilder *)builder {
    if (self = [super init]) {
        _requestId = builder.requestId;
        _timestamp = builder.timestamp;
    }
    return self;
}

@end
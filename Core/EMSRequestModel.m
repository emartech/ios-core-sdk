//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"

@implementation EMSRequestModel

+ (nonnull EMSRequestModel *)makeWithBuilder:(BuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    EMSRequestModelBuilder *builder = [EMSRequestModelBuilder new];
    builderBlock(builder);
    NSParameterAssert(builder.url);
    return [[EMSRequestModel alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(EMSRequestModelBuilder *)builder {
    if (self = [super init]) {
        _requestId = builder.requestId;
        _timestamp = builder.timestamp;
        _method = builder.method;
        _url = builder.url;
        _body = builder.body;
        _headers = builder.headers;
    }
    return self;
}

@end
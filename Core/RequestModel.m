//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "RequestModel.h"
#import "RequestModelBuilder.h"

@implementation RequestModel

+ (nonnull RequestModel *)makeWithBuilder:(BuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    RequestModelBuilder *builder = [RequestModelBuilder new];
    builderBlock(builder);
    NSParameterAssert(builder.url);
    return [[RequestModel alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(RequestModelBuilder *)builder {
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
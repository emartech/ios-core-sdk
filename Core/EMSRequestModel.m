//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"

@implementation EMSRequestModel

+ (nonnull EMSRequestModel *)makeWithBuilder:(EMSRequestBuilderBlock)builderBlock {
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

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToModel:other];
}

- (BOOL)isEqualToModel:(EMSRequestModel *)model {
    if (self == model)
        return YES;
    if (model == nil)
        return NO;
    if (self.requestId != model.requestId && ![self.requestId isEqualToString:model.requestId])
        return NO;
    if (self.timestamp != model.timestamp && ![self.timestamp isEqualToDate:model.timestamp])
        return NO;
    if (self.url != model.url && ![self.url isEqual:model.url])
        return NO;
    if (self.method != model.method && ![self.method isEqualToString:model.method])
        return NO;
    if (self.body != model.body && ![self.body isEqualToData:model.body])
        return NO;
    if (self.headers != model.headers && ![self.headers isEqualToDictionary:model.headers])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.requestId hash];
    hash = hash * 31u + [self.timestamp hash];
    hash = hash * 31u + [self.url hash];
    hash = hash * 31u + [self.method hash];
    hash = hash * 31u + [self.body hash];
    hash = hash * 31u + [self.headers hash];
    return hash;
}


@end
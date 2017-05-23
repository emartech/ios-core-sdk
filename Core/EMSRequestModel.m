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
    NSParameterAssert(builder.requestUrl);
    return [[EMSRequestModel alloc] initWithBuilder:builder];
}

- (instancetype)initWithRequestId:(NSString *)requestId
                        timestamp:(NSDate *)timestamp
                              url:(NSURL *)url
                           method:(NSString *)method
                          payload:(NSDictionary<NSString *, id> *)payload
                          headers:(NSDictionary<NSString *, NSString *> *)headers {
    if (self = [super init]) {
        _requestId = requestId;
        _timestamp = timestamp;
        _method = method;
        _url = url;
        _payload = payload;
        _headers = headers;
    }
    return self;
}


- (id)initWithBuilder:(EMSRequestModelBuilder *)builder {
    if (self = [super init]) {
        _requestId = builder.requestId;
        _timestamp = builder.timestamp;
        _method = builder.requestMethod;
        _url = builder.requestUrl;
        _payload = builder.payload;
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
    if (self.timestamp != model.timestamp && [self.timestamp timeIntervalSince1970] != [model.timestamp timeIntervalSince1970])
        return NO;
    if (self.url != model.url && ![self.url isEqual:model.url])
        return NO;
    if (self.method != model.method && ![self.method isEqualToString:model.method])
        return NO;
    if (self.payload != model.payload && ![self.payload isEqualToDictionary:model.payload])
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
    hash = hash * 31u + [self.payload hash];
    hash = hash * 31u + [self.headers hash];
    return hash;
}


@end
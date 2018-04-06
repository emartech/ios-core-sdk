//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSLoggerSettings.h"
#import "EMSLogger.h"

@interface EMSLoggerSettings ()

@property(nonatomic, strong, class) NSMutableSet<id <EMSLogTopicProtocol>> *topics;

@end

@implementation EMSLoggerSettings
static BOOL allEnabled;

+ (void)enableLogging:(NSArray<id <EMSLogTopicProtocol>> *)topics {
    [EMSLoggerSettings.topics addObjectsFromArray:topics];
}

+ (void)enableLoggingForAllTopics {
    allEnabled = YES;
}

+ (BOOL)isEnabled:(id <EMSLogTopicProtocol>)topic {
    return allEnabled || [EMSLoggerSettings.topics containsObject:topic];
}

+ (void)setTopics:(NSMutableSet<id<EMSLogTopicProtocol>> *)topics {
    EMSLoggerSettings.topics = topics;
}

+ (NSMutableSet<id<EMSLogTopicProtocol>> *)topics {
    return EMSLoggerSettings.topics;
}

@end

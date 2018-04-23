//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSLoggerSettings.h"
#import "EMSLogger.h"

@interface EMSLoggerSettings ()

@property(nonatomic, strong, class) NSMutableSet<NSString *> *topics;
@property(nonatomic, assign, class) BOOL allEnabled;

@end

@implementation EMSLoggerSettings

+ (void)enableLogging:(NSArray<id <EMSLogTopicProtocol>> *)topics {
    for (id <EMSLogTopicProtocol> topic in topics) {
        [EMSLoggerSettings.topics addObject:topic.topicTag];
    }
}

+ (void)enableLoggingForAllTopics {
    EMSLoggerSettings.allEnabled = YES;
}

+ (BOOL)isEnabled:(id <EMSLogTopicProtocol>)topic {
    return EMSLoggerSettings.allEnabled || [EMSLoggerSettings.topics containsObject:topic.topicTag];
}

@end

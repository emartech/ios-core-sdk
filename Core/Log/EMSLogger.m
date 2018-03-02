//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSLogger.h"
#import "EMSLoggerSettings.h"

@interface EMSLogger ()

+ (void)log:(NSString *)topicTag
    message:(NSString *)message;

+ (NSString *)currentThread;

+ (NSString *)callingStack;

@end

@implementation EMSLogger

#pragma mark - Public methods

+ (void)logWithTopic:(id <EMSLogTopicProtocol>)topic
             message:(NSString *)message {
    if ([EMSLoggerSettings isEnabled:topic]) {
        [EMSLogger log:topic.topicTag
               message:message];
    }
}

+ (void)logWithTopic:(id <EMSLogTopicProtocol>)topic
             message:(NSString *)message
           arguments:(NSObject *)arguments, ... {
    va_list args;
    va_start(args, arguments);
    while ((va_arg(args, NSObject *)));
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message
                                                        arguments:args];
    if ([EMSLoggerSettings isEnabled:topic]) {
        [EMSLogger log:topic.topicTag
               message:formattedMessage];
    }
    va_end(args);
}


#pragma mark - Private methods

+ (void)log:(NSString *)topicTag
    message:(NSString *)message {
    NSLog([NSString stringWithFormat:@"\n💡 Log - Topic: %@\nMessage: %@\n🔮️ Thread: %@\nCalling stack: %@", topicTag, message, [EMSLogger currentThread], [EMSLogger callingStack]]);
}

+ (NSString *)currentThread {
    return [[NSThread currentThread] description];
}

+ (NSString *)callingStack {
    NSMutableString *stackTrace = [NSMutableString string];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSArray<NSString *> *const stackSymbols = [NSThread callStackSymbols];
    for (int i = 0; i < 6; i++) {
        NSMutableArray<NSString *> *splittedStackRow = [[stackSymbols[(NSUInteger) i] componentsSeparatedByCharactersInSet:separatorSet] mutableCopy];
        [splittedStackRow removeObject:@""];
        [stackTrace appendString:[NSString stringWithFormat:@"\n⛓ Stack: %@ Framework: %@ Memory address: %@, Class caller: %@, Method caller: %@", splittedStackRow[0], splittedStackRow[1], splittedStackRow[2], splittedStackRow[3], splittedStackRow[4]]];
    }
    return stackTrace;
}

@end
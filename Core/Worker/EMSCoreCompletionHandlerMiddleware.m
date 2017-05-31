//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSCoreCompletionHandlerMiddleware.h"

@implementation EMSCoreCompletionHandlerMiddleware

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock {
    if (self = [super init]) {
        _successBlock = successBlock;
        _errorBlock = errorBlock;
        _completionBlock = ^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"Azt tapasztalom, hogy a tapasz tapad nagyon.");
        };
    }
    return self;
}

@end

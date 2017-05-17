//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteQueue.h"

@implementation EMSSQLiteQueue

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)push:(EMSRequestModel *)model {

}

- (EMSRequestModel *)pop {
    return nil;
}

- (EMSRequestModel *)peek {
    return nil;
}

- (BOOL)empty {
    return NO;
}

@end

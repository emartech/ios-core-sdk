//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestManager.h"

@protocol EMSWorkerProtocol;

@interface EMSRequestManager (Private)

- (instancetype)initWithWorker:(id <EMSWorkerProtocol>)worker
                         queue:(id <EMSQueueProtocol>)queue;

@end
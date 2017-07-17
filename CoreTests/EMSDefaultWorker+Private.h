//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDefaultWorker.h"

@interface EMSDefaultWorker (Private)

- (instancetype)initWithQueue:(id <EMSQueueProtocol>)queue
           connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                   restClient:(EMSRESTClient *)client;

- (void)setConnectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog;

- (void)setQueue:(id <EMSQueueProtocol>)queue;

- (void)setClient:(EMSRESTClient *)client;

@end
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestManager.h"

@protocol EMSWorkerProtocol;

@interface EMSRequestManager (Private)

- (instancetype)initWithWorker:(id <EMSWorkerProtocol>)worker
             requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository;

@end
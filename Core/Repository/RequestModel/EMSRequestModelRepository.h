//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSSQLiteHelper.h"

@interface EMSRequestModelRepository : NSObject <EMSRequestModelRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;

@end
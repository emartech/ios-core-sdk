//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "EMSQueueProtocol.h"

@class EMSSQLiteHelper;

@interface EMSSQLiteQueue : NSObject <EMSQueueProtocol>

- (instancetype)initWithSQLiteHelper:(EMSSQLiteHelper *)sqliteHelper;

@end

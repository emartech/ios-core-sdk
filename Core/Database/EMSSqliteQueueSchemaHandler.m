//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"

@implementation EMSSqliteQueueSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:SQL_CREATE_TABLE];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion {
}

- (int)schemaVersion {
    return 1;
}

@end
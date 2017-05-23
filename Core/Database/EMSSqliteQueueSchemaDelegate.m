//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaDelegate.h"
#import "EMSRequestContract.h"

@implementation EMSSqliteQueueSchemaDelegate

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:SQL_CREATE_TABLE];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion {
}

- (int)schemaVersion {
    return 1;
}

@end
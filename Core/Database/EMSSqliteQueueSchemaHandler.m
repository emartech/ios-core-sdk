//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaHandler.h"
#import "EMSRequestContract.h"
#import "EMSRequestModelBuilder.h"

@implementation EMSSqliteQueueSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:SQL_CREATE_TABLE];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion {
    if(oldversion == 1 && newVersion == 2) {
        [dbHelper executeCommand:SCHEMA_UPGRADE_FROM_1_TO_2];
        [dbHelper executeCommand:SET_DEFAULT_VALUES_FROM_1_TO_2 withTimeIntervalValue:DEFAULT_REQUESTMODEL_EXPIRY];
    }
}

- (int)schemaVersion {
    return 2;
}

@end
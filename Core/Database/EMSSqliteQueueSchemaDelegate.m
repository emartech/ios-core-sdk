//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteQueueSchemaDelegate.h"


@implementation EMSSqliteQueueSchemaDelegate

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:@"create table if not exists RequestModel (request_id TEXT, method TEXT, url TEXT, headers BLOB, payload BLOB, timestamp INTEGER);"];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion {

}

- (int)schemaVersion {
    return 1;
}

@end
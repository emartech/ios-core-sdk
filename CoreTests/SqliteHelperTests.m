//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaDelegate.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(SQLiteHelperTests)

    __block EMSSQLiteHelper *dbHelper;

    beforeEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                   error:nil];
        dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH];
    });

    afterEach(^{
        [dbHelper close];
    });

//    void (^shouldEqualWithValues)(NSString *sql, NSArray *expectedColumns) = ^(NSString *sql, NSArray *expectedColumns) {
//        EMSSQLiteHelper *helper = [EMSSQLiteHelper new];
//        [[NSFileManager defaultManager] removeItemAtPath:[helper databasePath] error:nil];
//
//        sqlite3 *db = [helper open];
//
//        sqlite3_stmt *statement;
//        if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
//            if(sqlite3_step(statement) == SQLITE_ROW) {
//                for (int i = 0; i < expectedColumns.count; i++) {
//                    [[theValue(sqlite3_column_int(statement, i)) should] equal:expectedColumns[(NSUInteger) i]];
//                }
//            } else {
//                fail(@"sqlite3_step failed");
//            }
//        } else {
//            fail(@"sqlite3_prepare_v2 failed");
//        };
//
//        [[theValue([[NSFileManager defaultManager] fileExistsAtPath:[helper databasePath]]) should] beTrue];
//        [helper close];
//    };

    void (^runCommandOnTestDB)(NSString *sql) = ^(NSString *sql) {
        sqlite3 *db;
        sqlite3_open([TEST_DB_PATH UTF8String], &db);
        sqlite3_stmt *statement1;
        sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement1, nil);
        sqlite3_step(statement1);
        sqlite3_close(db);
    };

    describe(@"getVersion", ^{

        it(@"should return the default version", ^{
            [dbHelper open];
            [[theValue([dbHelper version]) should] equal:@0];
        });

        it(@"should assert when version called in case of the db is not opened", ^{
            @try {
                [dbHelper version];
                fail(@"Expected exception when calling version in case the db is not opened");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }

        });

        it(@"should return the version set", ^{
            runCommandOnTestDB(@"PRAGMA user_version=42;");
            [dbHelper open];
            [[theValue([dbHelper version]) should] equal:@42];
        });

    });

    describe(@"open", ^{

        it(@"should call onCreate when the database is opened the first time", ^{
            EMSSqliteQueueSchemaDelegate *schemaDelegate = [EMSSqliteQueueSchemaDelegate mock];
            dbHelper.schemaDelegate = schemaDelegate;
            [[schemaDelegate should] receive:@selector(onCreateWithDbHelper:) withArguments:any()];

            [dbHelper open];
        });

        it(@"should call onUpgrade when the oldVersion and newVersion are different", ^{
            runCommandOnTestDB(@"PRAGMA user_version=2;");

            EMSSqliteQueueSchemaDelegate *schemaDelegate = [EMSSqliteQueueSchemaDelegate mock];
            dbHelper.schemaDelegate = schemaDelegate;
            [[schemaDelegate should] receive:@selector(onUpgradeWithDbHelper:oldVersion:newVersion:) withArguments:any(), theValue(2), theValue(SCHEMA_VERSION)];

            [dbHelper open];
        });

    });

    describe(@"executeCommand", ^{

        it(@"should return YES when successfully executeCommand on DB", ^{
            [dbHelper open];
            BOOL returnedValue = [dbHelper executeCommand:@"PRAGMA user_version=42;"];
            [dbHelper close];

            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil) == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    [[theValue(returnedValue) should] beTrue];
                    [[theValue(sqlite3_column_int(statement, 0)) should] equal:@42];
                } else {
                    fail(@"sqlite3_step failed");
                }
            } else {
                fail(@"sqlite3_prepare_v2 failed");
            };
            sqlite3_close(db);

        });

        it(@"should return NO when executeCommand failed", ^{
            [dbHelper open];
            BOOL returnedValue = [dbHelper executeCommand:@"invalid sql;"];
            [[theValue(returnedValue) should] beFalse];
        });

    });

    describe(@"schemaDelegate onCreate", ^{

        xit(@"should creates schema for RequestModel", ^{
            [dbHelper setSchemaDelegate:[EMSSqliteQueueSchemaDelegate new]];
            [dbHelper open];
            [dbHelper close];

            sqlite3 *db;
            sqlite3_open([TEST_DB_PATH UTF8String], &db);
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(db, [@"SELECT sql FROM sqlite_master WHERE type='table' AND name='RequestModel';" UTF8String], -1, &statement, nil) == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    [[[NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] should] equal:@"create table if not exists RequestModel (request_id TEXT, method TEXT, url TEXT, headers BLOB, payload BLOB, timestamp INTEGER);"];
                } else {
                    fail(@"sqlite3_step failed");
                }
            } else {
                fail(@"sqlite3_prepare_v2 failed");
            };
            sqlite3_close(db);
        });
    });

SPEC_END

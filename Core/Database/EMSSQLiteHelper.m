//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteHelper.h"
#import "EMSModelMapperProtocol.h"

@interface EMSSQLiteHelper ()

@property(nonatomic, assign) sqlite3 *db;
@property(nonatomic, strong) NSString *dbPath;

@end

@implementation EMSSQLiteHelper

- (instancetype)initWithDatabasePath:(NSString *)path {
    return [self initWithDatabasePath:path schemaDelegate:nil];
}

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaDelegate>)schemaDelegate {
    self = [super init];
    if (self) {
        _dbPath = path;
        _schemaDelegate = schemaDelegate;
    }

    return self;
}

- (int)version {
    NSParameterAssert(_db);

    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil);
    if (result == SQLITE_OK) {
        int step = sqlite3_step(statement);
        if (step == SQLITE_ROW) {
            return sqlite3_column_int(statement, 0);
        } else {
            return -2;
        }
    } else {
        return -1;
    };
}


- (void)open {
    if (sqlite3_open([self.dbPath UTF8String], &_db) == SQLITE_OK) {

        int version = [self version];
        if (version == 0) {
            [self.schemaDelegate onCreateWithDbHelper:self];
        } else {
            int newVersion = [self.schemaDelegate schemaVersion];
            if (version < newVersion) {
                [self.schemaDelegate onUpgradeWithDbHelper:self oldVersion:version newVersion:newVersion];
            }
        }
    }
}

- (void)close {
    sqlite3_close(_db);
    _db = nil;
}


- (BOOL)executeCommand:(NSString *)command {
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [command UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int value = sqlite3_step(statement);
        return value == SQLITE_ROW || value == SQLITE_DONE;
    }
    return NO;
}

- (BOOL)insertModel:(id)model withQuery:(NSString *)insertSQL mapper:(id <EMSModelMapperProtocol>)mapper {
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [insertSQL UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [mapper bindStatement:statement fromModel:model];
        int value = sqlite3_step(statement);
        sqlite3_finalize(statement);
        return value == SQLITE_DONE;
    }
    return NO;
}

- (NSArray *)executeQuery:(NSString *)query mapper:(id <EMSModelMapperProtocol>)mapper {
    NSMutableArray *models = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [models addObject:[mapper modelFromStatement:statement]];
        }
        return [NSArray arrayWithArray:models];
    }
    return nil;
}

@end
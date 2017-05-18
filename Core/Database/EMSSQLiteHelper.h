//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define SCHEMA_VERSION 3

@class EMSSQLiteHelper;
@protocol EMSSQLiteHelperSchemaDelegate

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper;

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldversion newVersion:(int)newVersion;

@end

@interface EMSSQLiteHelper : NSObject

@property(nonatomic, weak) id <EMSSQLiteHelperSchemaDelegate> schemaDelegate;

- (instancetype)initWithDatabasePath:(NSString *)path;

- (instancetype)initWithDatabasePath:(NSString *)path schemaDelegate:(id <EMSSQLiteHelperSchemaDelegate>)schemaDelegate;

- (int)version;

- (void)open;

- (void)close;

- (BOOL)executeCommand:(NSString *)command;

@end
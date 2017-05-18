//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define SCHEMA_VERSION 3

@protocol EMSSQLiteHelperSchemaDelegate

- (void)onCreateWithDatabase:(sqlite3 *)db;

- (void)onUpgradeWithDatabase:(sqlite3 *)db oldVersion:(int)oldversion newVersion:(int)newVersion;

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
//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class EMSSQLiteHelper;
@protocol EMSModelMapperProtocol;

@protocol EMSSQLiteHelperSchemaDelegate

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper;

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldVersion newVersion:(int)newVersion;

- (int)schemaVersion;

@end

@interface EMSSQLiteHelper : NSObject

@property(nonatomic, weak) id <EMSSQLiteHelperSchemaDelegate> schemaDelegate;

- (instancetype)initWithDatabasePath:(NSString *)path;

- (instancetype)initWithDatabasePath:(NSString *)path schemaDelegate:(id <EMSSQLiteHelperSchemaDelegate>)schemaDelegate;

- (int)version;

- (void)open;

- (void)close;

- (BOOL)executeCommand:(NSString *)command;

- (NSArray *)executeQuery:(NSString *)query mapper:(id <EMSModelMapperProtocol>)mapper;

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper;

@end
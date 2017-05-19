//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelMapper.h"
#import "EMSRequestModel.h"
#import "NSDictionary+EMSCore.h"

@implementation EMSRequestModelMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    return nil;
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(id)model2 {
    EMSRequestModel *model;
    sqlite3_bind_text(statement, 1, [[model requestId] UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 2, [[model method] UTF8String], -1, SQLITE_STATIC);
    sqlite3_bind_text(statement, 3, [[[model url] absoluteString] UTF8String], -1, SQLITE_STATIC);

    NSData *headers = [[model headers] archive];
    sqlite3_bind_blob(statement, 4, [headers bytes], [headers length], SQLITE_BLOB);
    NSData *payload = [[model payload] archive];
    sqlite3_bind_blob(statement, 5, [payload bytes], [payload length], SQLITE_BLOB);
    sqlite3_bind_int64(statement, 6, (sqlite3_int64) ([[model timestamp] timeIntervalSince1970] * 1000));

    return statement;
}

- (NSString *)insertStatement {
    return @"INSERT INTO RequestModel VALUES (request_id=?,method=?,url=?,headers=?,payload=?,timestamp=?)";
}


@end
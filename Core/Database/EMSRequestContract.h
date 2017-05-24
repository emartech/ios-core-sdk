//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

#define TABLE_NAME @"request"
#define COLUMN_NAME_REQUEST_ID @"request_id"
#define COLUMN_NAME_METHOD @"method"
#define COLUMN_NAME_URL @"url"
#define COLUMN_NAME_HEADERS @"headers"
#define COLUMN_NAME_PAYLOAD @"payload"
#define COLUMN_NAME_TIMESTAMP @"timestamp"

#define SQL_CREATE_TABLE [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ BLOB,%@ BLOB,%@ REAL);", TABLE_NAME, COLUMN_NAME_REQUEST_ID, COLUMN_NAME_METHOD, COLUMN_NAME_URL, COLUMN_NAME_HEADERS, COLUMN_NAME_PAYLOAD, COLUMN_NAME_TIMESTAMP]
#define SQL_INSERT [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?);", TABLE_NAME, COLUMN_NAME_REQUEST_ID, COLUMN_NAME_METHOD, COLUMN_NAME_URL, COLUMN_NAME_HEADERS, COLUMN_NAME_PAYLOAD, COLUMN_NAME_TIMESTAMP]
#define SQL_SELECTFIRST [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ROWID ASC LIMIT 1;", TABLE_NAME]
#define SQL_DELETE_ITEM [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?;", TABLE_NAME, COLUMN_NAME_REQUEST_ID]
#define SQL_PURGE [NSString stringWithFormat:@"DELETE FROM %@;", TABLE_NAME]
#define SQL_COUNT [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", TABLE_NAME]

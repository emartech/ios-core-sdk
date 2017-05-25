//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteQueue.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestContract.h"
#import "EMSRequestModelMapper.h"
#import "EMSCountMapper.h"

@interface EMSSQLiteQueue ()

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;

@end

@implementation EMSSQLiteQueue

- (instancetype)initWithSQLiteHelper:(EMSSQLiteHelper *)sqliteHelper {
    if (self = [super init]) {
        _dbHelper = sqliteHelper;
    }
    return self;
}

- (void)push:(EMSRequestModel *)model {
    NSParameterAssert(model);

    [self.dbHelper open];
    [self.dbHelper insertModel:model withQuery:SQL_INSERT mapper:[EMSRequestModelMapper new]];
    [self.dbHelper close];
}

- (EMSRequestModel *)pop {
    [self.dbHelper open];
    EMSRequestModel *model = [[self.dbHelper executeQuery:SQL_SELECTFIRST mapper:[EMSRequestModelMapper new]] firstObject];
    [self.dbHelper executeCommand:SQL_DELETE_ITEM withValue:[model requestId]];
    [self.dbHelper close];
    return model;
}

- (EMSRequestModel *)peek {
    [self.dbHelper open];
    EMSRequestModel *model = [[self.dbHelper executeQuery:SQL_SELECTFIRST mapper:[EMSRequestModelMapper new]] firstObject];
    [self.dbHelper close];
    return model;
}

- (BOOL)empty {
    [self.dbHelper open];
    NSNumber *count = [[self.dbHelper executeQuery:SQL_COUNT mapper:[EMSCountMapper new]] firstObject];
    [self.dbHelper close];
    return [count integerValue] == 0;
}

@end

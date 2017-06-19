//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteQueue.h"
#import "EMSSQLiteHelper.h"
#import "EMSRequestContract.h"
#import "EMSRequestModelMapper.h"
#import "EMSCountMapper.h"
#import <UIKit/UIKit.h>

@interface EMSSQLiteQueue ()

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;

@end

@implementation EMSSQLiteQueue

- (instancetype)initWithSQLiteHelper:(EMSSQLiteHelper *)sqliteHelper {
    if (self = [super init]) {
        _dbHelper = sqliteHelper;
        [_dbHelper open];

        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf.dbHelper close];
        }];
    }
    return self;
}

- (void)push:(EMSRequestModel *)model {
    NSParameterAssert(model);

    [self.dbHelper insertModel:model withQuery:SQL_INSERT mapper:[EMSRequestModelMapper new]];
}

- (EMSRequestModel *)pop {
    EMSRequestModel *model = [[self.dbHelper executeQuery:SQL_SELECTFIRST mapper:[EMSRequestModelMapper new]] firstObject];
    [self.dbHelper executeCommand:SQL_DELETE_ITEM withValue:[model requestId]];
    return model;
}

- (EMSRequestModel *)peek {
    EMSRequestModel *model = [[self.dbHelper executeQuery:SQL_SELECTFIRST mapper:[EMSRequestModelMapper new]] firstObject];
    return model;
}

- (BOOL)isEmpty {
    NSNumber *count = [[self.dbHelper executeQuery:SQL_COUNT mapper:[EMSCountMapper new]] firstObject];
    return [count integerValue] == 0;
}

@end

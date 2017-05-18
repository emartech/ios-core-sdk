//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteQueue.h"
#import "EMSSQLiteHelper.h"

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

}

- (EMSRequestModel *)pop {
    return nil;
}

- (EMSRequestModel *)peek {
    return nil;
}

- (BOOL)empty {
    return NO;
}

@end

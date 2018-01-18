//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSRequestModelFilterSelectFirstSpecification.h"
#import "EMSRequestContract.h"

@implementation EMSRequestModelFilterSelectFirstSpecification

- (NSString *)sql {
    return SQL_SELECTFIRST;
}

- (void)bindStatement:(sqlite3_stmt *)statement {
}

@end
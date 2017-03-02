//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EMSCore)

+ (NSString *)createBasicAuthWith:(NSString *)username
                         password:(NSString *)password;

@end
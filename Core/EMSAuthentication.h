//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSAuthentication : NSObject

+ (NSString *)createBasicAuthWithUsername:(NSString *)username
                                 password:(NSString *)password;
@end
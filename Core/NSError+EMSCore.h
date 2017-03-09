//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (EMSCore)

+ (NSError *)errorWithCode:(int)errorCode
      localizedDescription:(NSString *)localizedDescription;

@end
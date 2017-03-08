//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSDeviceInfo: NSObject

+ (NSString *)timeZone;
+ (NSString *)languageCode;
+ (NSString *)applicationVersion;
+ (NSString *)deviceModel;
+ (NSString *)osVersion;
+ (NSString *)hardwareId;

@end
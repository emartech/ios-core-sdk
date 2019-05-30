//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EMSDeviceInfo: NSObject

+ (NSString *)timeZone;
+ (NSString *)languageCode;

+ (nullable NSString *)applicationVersion;
+ (NSString *)deviceModel;

+ (NSString *)deviceType;
+ (NSString *)osVersion;
+ (NSString *)hardwareId;

+ (NSDictionary *)pushSettings;

@end

NS_ASSUME_NONNULL_END
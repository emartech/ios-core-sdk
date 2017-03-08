//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDeviceInfo.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

@implementation EMSDeviceInfo

#define kHardwareIdKey @"kHardwareIdKey"

+ (NSString *)timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"xxxx";
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSString *)languageCode {
    NSString *language = [NSLocale preferredLanguages][0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    NSString *languageCode = languageDic[(NSString *) kCFLocaleLanguageCode];
    return languageCode;
}

+ (NSString *)applicationVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine);
}

+ (NSString *)osVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)hardwareId {
    NSString *hardwareId = [[NSUserDefaults standardUserDefaults] objectForKey:kHardwareIdKey];

    if(!hardwareId) {
        hardwareId = [self getNewHardwareId];
        [[NSUserDefaults standardUserDefaults] setObject:hardwareId forKey:kHardwareIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return hardwareId;
}

+ (NSString *)getNewHardwareId {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier]
                UUIDString];
    }
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end
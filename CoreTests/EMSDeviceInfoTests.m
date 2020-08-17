//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import <OCMock/OCMock.h>
#import <UserNotifications/UNNotificationSettings.h>
#import "EMSDeviceInfo.h"
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>

SPEC_BEGIN(EMSDeviceInfoTests)

        context(@"Timezone", ^{
            __block NSTimeZone *cachedTimeZone;

            beforeAll(^{
                cachedTimeZone = [NSTimeZone defaultTimeZone];
                [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Budapest"]];
            });

            afterAll(^{
                [NSTimeZone setDefaultTimeZone:cachedTimeZone];
            });

            describe(@"timeZone", ^{

                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo timeZone] shouldNot] beNil];
                });

                it(@"should return with the current timeZone", ^{
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.timeZone = [NSTimeZone localTimeZone];
                    formatter.dateFormat = @"xxxx";
                    NSString *expected = [formatter stringFromDate:[NSDate date]];

                    NSString *timeZone = [EMSDeviceInfo timeZone];
                    [[timeZone should] equal:expected];
                });

            });

            describe(@"languageCode", ^{
                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo languageCode] shouldNot] beNil];
                });
            });

            describe(@"deviceModel", ^{
                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo deviceModel] shouldNot] beNil];
                });
            });

            describe(@"deviceType", ^{

                void (^setUserInterfaceIdiom)(NSInteger userInterfaceIdiom) = ^(NSInteger userInterfaceIdiom) {
                    UIDevice *uiDevice = [UIDevice mock];
                    [[uiDevice should] receive:@selector(userInterfaceIdiom) andReturn:theValue(userInterfaceIdiom)];

                    [[UIDevice should] receive:@selector(currentDevice) andReturn:uiDevice];
                };

                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo deviceType] shouldNot] beNil];
                });

                it(@"should return iPhone type", ^{
                    setUserInterfaceIdiom(UIUserInterfaceIdiomPhone);

                    [[[EMSDeviceInfo deviceType] should] equal:@"iPhone"];
                });

                it(@"should return iPad type", ^{
                    setUserInterfaceIdiom(UIUserInterfaceIdiomPad);

                    [[[EMSDeviceInfo deviceType] should] equal:@"iPad"];
                });

            });

            describe(@"osVersion", ^{
                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo osVersion] shouldNot] beNil];
                });
            });
        });

        if (@available(iOS 11.0, *)) {
            describe(@"pushSettings", ^{

                NSDictionary *(^setupNotificationSetting)(SEL sel, NSInteger returnValue) = ^NSDictionary *(SEL sel, NSInteger returnValue) {
                    UNNotificationSettings *mockNotificationSetting = [UNNotificationSettings nullMock];
                    [mockNotificationSetting stub:sel
                                        andReturn:theValue(returnValue)];

                    id mockCenter = OCMClassMock([UNUserNotificationCenter class]);

                    OCMStub(ClassMethod([mockCenter currentNotificationCenter])).andReturn(mockCenter);

                    OCMStub([mockCenter getNotificationSettingsWithCompletionHandler:[OCMArg invokeBlockWithArgs:mockNotificationSetting]]);

                    NSDictionary *result = [EMSDeviceInfo pushSettings];

                    return result;
                };

                it(@"should contain authorizationStatus with value authorized", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusAuthorized);

                    [[result[@"authorization_status"] should] equal:@"authorized"];
                });

                it(@"should contain authorizationStatus with value denied", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusDenied);

                    [[result[@"authorization_status"] should] equal:@"denied"];
                });
                if (@available(iOS 12.0, *)) {
                    it(@"should contain authorizationStatus with value provisional", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusProvisional);

                        [[result[@"authorization_status"] should] equal:@"provisional"];
                    });
                }
                it(@"should contain authorizationStatus with value notDetermined", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(authorizationStatus), UNAuthorizationStatusNotDetermined);

                    [[result[@"authorization_status"] should] equal:@"notDetermined"];
                });

                it(@"should contain soundSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingNotSupported);

                    [[result[@"sound_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain soundSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingDisabled);

                    [[result[@"sound_setting"] should] equal:@"disabled"];
                });

                it(@"should contain soundSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(soundSetting), UNNotificationSettingEnabled);

                    [[result[@"sound_setting"] should] equal:@"enabled"];
                });

                it(@"should contain badgeSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingNotSupported);

                    [[result[@"badge_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain badgeSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingDisabled);

                    [[result[@"badge_setting"] should] equal:@"disabled"];
                });

                it(@"should contain badgeSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(badgeSetting), UNNotificationSettingEnabled);

                    [[result[@"badge_setting"] should] equal:@"enabled"];
                });

                it(@"should contain alertSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingNotSupported);

                    [[result[@"alert_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain alertSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingDisabled);

                    [[result[@"alert_setting"] should] equal:@"disabled"];
                });

                it(@"should contain alertSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertSetting), UNNotificationSettingEnabled);

                    [[result[@"alert_setting"] should] equal:@"enabled"];
                });

                it(@"should contain notificationCenterSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingNotSupported);

                    [[result[@"notification_center_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain notificationCenterSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingDisabled);

                    [[result[@"notification_center_setting"] should] equal:@"disabled"];
                });

                it(@"should contain notificationCenterSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(notificationCenterSetting), UNNotificationSettingEnabled);

                    [[result[@"notification_center_setting"] should] equal:@"enabled"];
                });

                it(@"should contain lockScreenSetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingNotSupported);

                    [[result[@"lock_screen_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain lockScreenSetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingDisabled);

                    [[result[@"lock_screen_setting"] should] equal:@"disabled"];
                });

                it(@"should contain lockScreenSetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(lockScreenSetting), UNNotificationSettingEnabled);

                    [[result[@"lock_screen_setting"] should] equal:@"enabled"];
                });

                it(@"should contain carPlaySetting with value notSupported", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingNotSupported);

                    [[result[@"car_play_setting"] should] equal:@"notSupported"];
                });

                it(@"should contain carPlaySetting with value disabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingDisabled);

                    [[result[@"car_play_setting"] should] equal:@"disabled"];
                });

                it(@"should contain carPlaySetting with value enabled", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(carPlaySetting), UNNotificationSettingEnabled);

                    [[result[@"car_play_setting"] should] equal:@"enabled"];
                });

                it(@"should contain alertStyle with value none", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleNone);

                    [[result[@"alert_style"] should] equal:@"none"];
                });

                it(@"should contain alertStyle with value banner", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleBanner);

                    [[result[@"alert_style"] should] equal:@"banner"];
                });

                it(@"should contain alertStyle with value alert", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(alertStyle), UNAlertStyleAlert);

                    [[result[@"alert_style"] should] equal:@"alert"];
                });

                it(@"should contain showPreviewsSetting with value never", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingNever);

                    [[result[@"show_previews_setting"] should] equal:@"never"];
                });

                it(@"should contain showPreviewsSetting with value whenAuthenticated", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingWhenAuthenticated);

                    [[result[@"show_previews_setting"] should] equal:@"whenAuthenticated"];
                });

                it(@"should contain showPreviewsSetting with value always", ^{
                    NSDictionary *result = setupNotificationSetting(@selector(showPreviewsSetting), UNShowPreviewsSettingAlways);

                    [[result[@"show_previews_setting"] should] equal:@"always"];
                });
                if (@available(iOS 12.0, *)) {
                    it(@"should contain criticalAlertSetting with value notSupported", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingNotSupported);

                        [[result[@"critical_alert_setting"] should] equal:@"notSupported"];
                    });

                    it(@"should contain criticalAlertSetting with value disabled", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingDisabled);

                        [[result[@"critical_alert_setting"] should] equal:@"disabled"];
                    });

                    it(@"should contain criticalAlertSetting with value enabled", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(criticalAlertSetting), UNNotificationSettingEnabled);

                        [[result[@"critical_alert_setting"] should] equal:@"enabled"];
                    });

                    it(@"should contain providesAppNotificationSettings with value NO", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(providesAppNotificationSettings), NO);

                        [[result[@"provides_app_notification_settings"] should] equal:@(NO)];
                    });

                    it(@"should contain providesAppNotificationSettings with value YES", ^{
                        NSDictionary *result = setupNotificationSetting(@selector(providesAppNotificationSettings), YES);

                        [[result[@"provides_app_notification_settings"] should] equal:@(YES)];
                    });
                }
            });
        }

        context(@"HWID", ^{

            describe(@"hardwareId", ^{

                it(@"should not return nil", ^{
                    [[[EMSDeviceInfo hardwareId] shouldNot] beNil];
                });

            });
        });

SPEC_END

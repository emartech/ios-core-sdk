//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSConnectionWatchdog.h"

SPEC_BEGIN(EMSConnectionWatchdogTest)


    beforeEach(^{
    });

    afterEach(^{
    });


    describe(@"connectionState", ^{

        it(@"should be NotReachable when it's really not reachable", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(NotReachable)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog connectionState]) should] equal:@(NotReachable)];
        });

        it(@"should be ReachableViaWiFi when it's ReachableViaWiFi", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWiFi)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog connectionState]) should] equal:@(ReachableViaWiFi)];
        });

        it(@"should be ReachableViaWWAN when it's ReachableViaWWAN", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWWAN)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog connectionState]) should] equal:@(ReachableViaWWAN)];
        });

    });

    describe(@"isConnected", ^{

        it(@"should be NO when it's not reachable", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(NotReachable)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog isConnected]) should] beNo];
        });

        it(@"should be YES when it's ReachableViaWiFi", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWiFi)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog isConnected]) should] beYes];
        });

        it(@"should be YES when it's ReachableViaWWAN", ^{
            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWWAN)];

            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            [[@([watchdog isConnected]) should] beYes];
        });

    });

    describe(@"connectionChangeListener", ^{
        it(@"should be called when connection status changes", ^{
            NSObject<EMSConnectionChangeListener> *listener = [NSObject mock];
            [[listener shouldEventually] receive:@selector(connectionChangedToNetworkStatus:connectionStatus:) withArguments:@(ReachableViaWiFi), @YES];

            EMSReachability *reachabilityMock = [EMSReachability mock];
            [[reachabilityMock should] receive:@selector(startNotifier) andReturn:@YES];
            [[reachabilityMock should] receive:@selector(currentReachabilityStatus) andReturn:theValue(ReachableViaWiFi) withCountAtLeast:1];
            EMSConnectionWatchdog *watchdog = [[EMSConnectionWatchdog alloc] initWithReachability:reachabilityMock];
            watchdog.connectionChangeListener = listener;

            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:reachabilityMock];
        });
    });


SPEC_END

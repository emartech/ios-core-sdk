//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConnectionWatchdog.h"
#import "EMSCoreTopic.h"

@interface EMSConnectionWatchdog ()

@property(nonatomic, strong) EMSReachability *reachability;
@property(nonatomic, strong) id notificationToken;

@end

@implementation EMSConnectionWatchdog

- (instancetype)init {
    return [self initWithReachability:[EMSReachability reachabilityForInternetConnection]];
}

- (instancetype)initWithReachability:(EMSReachability *)reachability {
    self = [super init];
    if (self) {
        _reachability = reachability;
    }

    return self;
}

- (EMSNetworkStatus)connectionState {
    return [self.reachability currentReachabilityStatus];
}

- (BOOL)isConnected {
    int state = [self connectionState];
    BOOL result = state == ReachableViaWiFi || state == ReachableViaWWAN;
    [EMSLogger logWithTopic:EMSCoreTopic.connectivityTopic
                    message:@"Connected to network: %@"
                  arguments:result ? @"Connected" : @"Not connected"];
    return result;
}

- (void)setConnectionChangeListener:(id <EMSConnectionChangeListener>)connectionChangeListener {
    _connectionChangeListener = connectionChangeListener;

    if (_connectionChangeListener) {
        [self startObserving];
    } else {
        [self stopObserving];
    }

}

- (void)stopObserving {
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationToken];
}

- (void)startObserving {
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:kEMSReachabilityChangedNotification
                                                                               object:self.reachability
                                                                                queue:[NSOperationQueue currentQueue]
                                                                           usingBlock:^(NSNotification *note) {
                                                                               NSString *connected = [weakSelf isConnected] ? @"Connected" : @"Not connected";
                                                                               NSString *networkStatus;
                                                                               switch ([weakSelf connectionState]) {
                                                                                   case NotReachable: {
                                                                                       networkStatus = @"Not reachable";
                                                                                   }
                                                                                       break;
                                                                                   case ReachableViaWiFi: {
                                                                                       networkStatus = @"WiFi";
                                                                                   }
                                                                                       break;
                                                                                   case ReachableViaWWAN: {
                                                                                       networkStatus = @"Mobile network";
                                                                                   }
                                                                                       break;
                                                                                   default: {
                                                                                       networkStatus = @"Not reachable";
                                                                                   }
                                                                               }
                                                                               [EMSLogger logWithTopic:EMSCoreTopic.connectivityTopic
                                                                                               message:@"Network status: %@, Connected to network: %@"
                                                                                             arguments:networkStatus, connected];
                                                                               [weakSelf.connectionChangeListener connectionChangedToNetworkStatus:[weakSelf connectionState]
                                                                                                                                  connectionStatus:[weakSelf isConnected]];
                                                                           }];
    [self.reachability startNotifier];
}

@end

//
//  RAReachabilityDefines.h
//  RAReachability
//
//  Created by Evadne Wu on 10/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

enum RAReachabilityState {
  RAReachabilityStateUnknown = -1,
  RAReachabilityStateNotAvailable = 0,
  RAReachabilityStateAvailable = 1024
}; typedef NSInteger RAReachabilityState;

typedef struct sockaddr_in RASocketAddress;
typedef void (^RAReachabilityCheckAliveCallback)(BOOL didFinish, NSError *error);

extern RASocketAddress RASocketAddressCreateLinkLocal (void);
extern RASocketAddress RASocketAddressCreateZero (void);

extern BOOL RASCNetworkRequiresConnection (SCNetworkReachabilityFlags flags);
extern BOOL RASCNetworkReachable (SCNetworkReachabilityFlags flags);
extern BOOL RASCNetworkReachableDirectly (SCNetworkReachabilityFlags flags);
extern BOOL RASCNetworkReachableViaWifi (SCNetworkReachabilityFlags flags);
extern BOOL RASCNetworkReachableViaWWAN (SCNetworkReachabilityFlags flags);

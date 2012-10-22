//
//  RAReachabilityDefines.m
//  RAReachability
//
//  Created by Evadne Wu on 10/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAReachabilityDefines.h"

RASocketAddress RASocketAddressCreateLinkLocal (void) {
	
	struct sockaddr_in linkLocalAddress;
	bzero(&linkLocalAddress, sizeof(linkLocalAddress));
	linkLocalAddress.sin_len = sizeof(linkLocalAddress);
	linkLocalAddress.sin_family = AF_INET;
	linkLocalAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	
	return linkLocalAddress;
	
}

RASocketAddress RASocketAddressCreateZero (void) {
	
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	return zeroAddress;
	
}

BOOL RASCNetworkRequiresConnection (SCNetworkReachabilityFlags flags) {
	
	return (BOOL)!!(flags & kSCNetworkReachabilityFlagsConnectionRequired);
	
}

BOOL RASCNetworkReachable (SCNetworkReachabilityFlags flags) {
	
	return (BOOL)!!(flags & kSCNetworkReachabilityFlagsReachable);
	
}

BOOL RASCNetworkReachableDirectly (SCNetworkReachabilityFlags flags) {
	
	if (flags & kSCNetworkReachabilityFlagsReachable)
		if (flags & kSCNetworkReachabilityFlagsIsDirect)
			return YES;
	
	return NO;
	
}

BOOL RASCNetworkReachableViaWifi (SCNetworkReachabilityFlags flags) {
	
	if (!RASCNetworkReachable(flags))
		return NO;
	
	if (!(flags & kSCNetworkReachabilityFlagsConnectionOnDemand))
		if (!(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic))
			return NO;
	
	return (BOOL)!(flags & kSCNetworkReachabilityFlagsInterventionRequired);
	
}

BOOL RASCNetworkReachableViaWWAN (SCNetworkReachabilityFlags flags) {
	
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	
	if (!RASCNetworkReachable(flags))
		return NO;
	
	return (BOOL)!!(flags & kSCNetworkReachabilityFlagsIsWWAN);
	
#else
	
	//	We don’t really need to handle this on a Mac
	
	return NO;
	
#endif
	
}

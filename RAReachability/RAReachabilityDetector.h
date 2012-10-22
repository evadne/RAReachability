//
//  RAReachabilityDetector.m
//  RAReachability
//
//  Created by Evadne Wu on 11/25/11.
//  Copyright (c) 2011 Radius. All rights reserved.
//

#import "RAReachabilityDefines.h"
#import "RAReachabilityDetectorDelegate.h"

@interface RAReachabilityDetector : NSObject

- (instancetype) initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef;
- (instancetype) initWithAddress:(RASocketAddress)anAddress;
- (instancetype) initWithURL:(NSURL *)aHostURL;

@property (nonatomic, readonly, assign) RASocketAddress hostAddress;
@property (nonatomic, readonly, strong) NSURL *hostURL;
@property (nonatomic, readonly, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, readonly, assign) SCNetworkReachabilityFlags networkStateFlags;
@property (nonatomic, readwrite, weak) id<RAReachabilityDetectorDelegate> delegate;

+ (id) newDetectorForInternet;
+ (id) newDetectorForLocalWiFi;

- (NSComparisonResult) compare:(RAReachabilityDetector *)otherDetector;
- (NSDictionary *) descriptionAttributes;

@end

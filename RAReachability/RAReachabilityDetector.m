//
//  RAReachabilityDetector.m
//  RAReachability
//
//  Created by Evadne Wu on 11/25/11.
//  Copyright (c) 2011 Radius. All rights reserved.
//

#import "RAReachabilityDetector.h"

extern void WASCReachabilityCallback (SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);

@implementation RAReachabilityDetector

@synthesize delegate = _delegate;
@synthesize hostURL = _hostURL;
@synthesize hostAddress = _hostAddress;
@synthesize networkStateFlags = _networkStateFlags;
@synthesize reachability = _reachability;

+ (id) newDetectorForInternet {

	return [[self alloc] initWithAddress:RASocketAddressCreateZero()];
	
}

+ (id) newDetectorForLocalWiFi {
	
	return [[self alloc] initWithAddress:RASocketAddressCreateLinkLocal()];
	
}

- (id) init {
	
	return [self initWithURL:nil];
	
}

- (instancetype) initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {

	self = [super init];
	if (!self)
		return nil;
	
	if (reachabilityRef) {
	
		_reachability = reachabilityRef;
		SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
		SCNetworkReachabilitySetCallback(_reachability, WASCReachabilityCallback, &context);
		SCNetworkReachabilitySetDispatchQueue(_reachability, dispatch_get_main_queue());
	
	}
	
	return self;

}

- (id) initWithAddress:(struct sockaddr_in)hostAddressRef {
	
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *)&_hostAddress);
	
	self = [self initWithReachabilityRef:reachabilityRef];
	if (!self) {
		if (reachabilityRef) {
			CFRelease(reachabilityRef);
		}
		return nil;
	}
	
	_hostAddress = hostAddressRef;
	
	return self;
	
}

- (id) initWithURL:(NSURL *)hostURL {
	
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [[hostURL host] UTF8String]);
	
	self = [self initWithReachabilityRef:reachabilityRef];
	if (!self) {
		if (reachabilityRef) {
			CFRelease(reachabilityRef);
		}
		return nil;
	}
	
	_hostURL = hostURL;
		
	return self;
	
}

- (SCNetworkReachabilityFlags) networkStateFlags {
	
	SCNetworkReachabilityFlags foundFlags = 0;
	if (!SCNetworkReachabilityGetFlags(self.reachability, &foundFlags))
		NSLog(@"Found flags are bad!");
	
	return foundFlags;
	
}

- (void) dealloc {
	
	if (_reachability) {
		SCNetworkReachabilitySetDispatchQueue(_reachability, NULL);
		CFRelease(_reachability);
	}
	
}

- (NSComparisonResult) compare:(RAReachabilityDetector *)otherDetector {

	RAReachabilityDetector *lhsReachabilityDetector = self;
	RAReachabilityDetector *rhsReachabilityDetector = otherDetector;
	
	SCNetworkReachabilityFlags lhsFlags = lhsReachabilityDetector.networkStateFlags;
	SCNetworkReachabilityFlags rhsFlags = rhsReachabilityDetector.networkStateFlags;
	
	BOOL lhsReachable = RASCNetworkReachable(lhsFlags);
	BOOL rhsReachable = RASCNetworkReachable(rhsFlags);
	
	if (!lhsReachable && !rhsReachable)
		return NSOrderedSame;
	else if (lhsReachable && !rhsReachable)
		return NSOrderedAscending;
	else if (!lhsReachable && rhsReachable)
		return NSOrderedDescending;
	
	BOOL lhsIsDirect = RASCNetworkReachableDirectly(lhsFlags);
	BOOL rhsIsDirect = RASCNetworkReachableDirectly(rhsFlags);
	
	if (lhsIsDirect && !rhsIsDirect)
		return NSOrderedAscending;
	else if (!lhsIsDirect && rhsIsDirect)
		return NSOrderedDescending;
	
	BOOL lhsOnWiFi = RASCNetworkReachableViaWifi(lhsFlags);
	BOOL rhsOnWiFi = RASCNetworkReachableViaWifi(rhsFlags);
	
	if (lhsOnWiFi && !rhsOnWiFi)
		return NSOrderedAscending;
	else if (!lhsOnWiFi && rhsOnWiFi)
		return NSOrderedDescending;
	
	BOOL lhsOnWWAN = RASCNetworkReachableViaWWAN(lhsFlags);
	BOOL rhsOnWWAN = RASCNetworkReachableViaWWAN(rhsFlags);
	
	if (lhsOnWWAN && !rhsOnWWAN)
		return NSOrderedAscending;
	else if (!lhsOnWWAN && rhsOnWWAN)
		return NSOrderedDescending;
	
	return NSOrderedSame;

}

- (NSDictionary *) descriptionAttributes {

	return @{
		@"Host": _hostURL,
		@"Network Reachability Flags": @(_networkStateFlags),
		@"Requires Connection": @(RASCNetworkRequiresConnection(_networkStateFlags)),
		@"Reachable": @(RASCNetworkReachable(_networkStateFlags)),
		@"Reachable Directly": @(RASCNetworkReachableDirectly(_networkStateFlags)),
		@"Reachable Thru WiFi": @(RASCNetworkReachableViaWifi(_networkStateFlags)),
		@"Reachable Thru WWAN": @(RASCNetworkReachableViaWWAN(_networkStateFlags))
	};

}

- (NSString *) description {

	NSArray * (^mapPair)(NSDictionary *, id(^)(id, id)) = ^ (NSDictionary *dictionary, id(^block)(id, id)) {
		
		NSUInteger capacity = [dictionary count];
		if (!capacity)
			return @[];
		
		NSMutableArray *answer = [NSMutableArray arrayWithCapacity:capacity];
		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[answer addObject:block(key, obj)];
		}];
		
		return (NSArray *)answer;
		
	};
	
	return [NSString stringWithFormat:@"<%@: %p { %@ }>",
	
		self,
		self,
		[mapPair(self.descriptionAttributes, ^(id key, id obj){
			return [NSString stringWithFormat:@"%@: %@", key, obj];
		}) componentsJoinedByString:@"; "]
	
	];
	
}

@end

extern void WASCReachabilityCallback (SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
	
	RAReachabilityDetector *self = (__bridge RAReachabilityDetector *)info;
	NSCParameterAssert(self);
	NSCParameterAssert([self isKindOfClass:[RAReachabilityDetector class]]);
	
	[self willChangeValueForKey:@"networkStateFlags"];
	[self.delegate reachabilityDetectorDidUpdateState:self];
	[self didChangeValueForKey:@"networkStateFlags"];
	
}

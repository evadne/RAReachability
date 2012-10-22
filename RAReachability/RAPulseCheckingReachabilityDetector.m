//
//  RAPulseCheckingReachabilityDetector.m
//  RAReachability
//
//  Created by Evadne Wu on 10/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPulseCheckingReachabilityDetector.h"

@interface RAPulseCheckingReachabilityDetector ()
@property (nonatomic, readwrite, assign) RAReachabilityState state;
@property (nonatomic, readwrite, strong) NSTimer *pulseCheckingTimer;
@end

@implementation RAPulseCheckingReachabilityDetector
@synthesize state = _state;
@synthesize pulseCheckingTimer = _pulseCheckingTimer;

- (id) initWithURL:(NSURL *)aHostURL {

	self = [super initWithURL:aHostURL];
	if (!self)
		return nil;
	
	_state = RAReachabilityStateUnknown;
	
	[self handlePulseCheckingTimer:nil];
	
	return self;

}

- (NSTimeInterval) pulseCheckingInterval {

	return 30.0f;

}

- (void) handlePulseCheckingTimer:(NSTimer *)timer {

	__weak typeof(self) wSelf = self;

	[self executePulseCheckingBlockWithCallback:^(BOOL didFinish, NSError *error) {
		
		if (!wSelf)
			return;
		
		NSCParameterAssert([NSThread isMainThread]);
		
		if (didFinish) {
		
			wSelf.state = RAReachabilityStateAvailable;
		
		} else {
		
			wSelf.state = RAReachabilityStateNotAvailable;
		
		}
		
		NSCParameterAssert(!wSelf.pulseCheckingTimer);
		wSelf.pulseCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:[wSelf pulseCheckingInterval] target:wSelf selector:@selector(handlePulseCheckingTimer:) userInfo:nil repeats:NO];
		
	}];
	
}

- (void) executePulseCheckingBlockWithCallback:(RAReachabilityCheckAliveCallback)callback {

	callback(YES, nil);

}

- (void) setState:(RAReachabilityState)state {

	_state = state;
	
	[self.delegate reachabilityDetectorDidUpdateState:self];

}

- (NSComparisonResult) compare:(RAReachabilityDetector *)otherDetector {
		
	if ([otherDetector isKindOfClass:[RAPulseCheckingReachabilityDetector class]]) {
	
		RAPulseCheckingReachabilityDetector *lhsReachabilityDetector = self;
		RAPulseCheckingReachabilityDetector *rhsReachabilityDetector = (RAPulseCheckingReachabilityDetector *)otherDetector;
		
		RAReachabilityState lhsState = lhsReachabilityDetector.state;
		RAReachabilityState rhsState = rhsReachabilityDetector.state;
		
		BOOL lhsAppLayerAlive = (lhsState == RAReachabilityStateAvailable);
		BOOL rhsAppLayerAlive = (rhsState == RAReachabilityStateAvailable);
		
		if (!lhsAppLayerAlive && !rhsAppLayerAlive)
			return NSOrderedSame;
		else if (lhsAppLayerAlive && !rhsAppLayerAlive)
			return NSOrderedAscending;
		else if (!lhsAppLayerAlive && rhsAppLayerAlive)
			return NSOrderedDescending;
	
	}
	
	return [super compare:otherDetector];
	
}

- (NSDictionary *) descriptionAttributes {

	NSMutableDictionary *attributes = [[super descriptionAttributes] mutableCopy];
	
	[attributes addEntriesFromDictionary:@{
		@"Pulse State": @(self.state)
	}];
	
	return attributes;

}

@end

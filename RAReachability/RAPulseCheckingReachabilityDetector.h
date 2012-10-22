//
//  RAPulseCheckingReachabilityDetector.h
//  RAReachability
//
//  Created by Evadne Wu on 10/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAReachabilityDetector.h"

@interface RAPulseCheckingReachabilityDetector : RAReachabilityDetector

- (id) initWithURL:(NSURL *)aHostURL;
@property (nonatomic, readonly, assign) RAReachabilityState state;

- (void) executePulseCheckingBlockWithCallback:(RAReachabilityCheckAliveCallback)callback;	//	subclass

@end

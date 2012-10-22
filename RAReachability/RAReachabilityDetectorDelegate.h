//
//  RAReachabilityDetectorDelegate.h
//  RAReachability
//
//  Created by Evadne Wu on 10/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RAReachabilityDetector;
@protocol RAReachabilityDetectorDelegate <NSObject>

- (void) reachabilityDetectorDidUpdateState:(RAReachabilityDetector *)detector;

@end

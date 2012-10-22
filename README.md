# RAReachability

Yet another SystemConfiguration Reachability Wrapper.

## What’s Inside

The project gives you **RAReachabilityDetector** which is a very lightweight abstraction around `SCNetworkReachabilityRef` provided by SystemConfiguration.  You can monitor anything a `SCNetworkReachabilityRef` already monitors, and use Cocoa-style delegation to handle changes in network configuration.

If you just want to see if WiFi works, for example, do this:

	self.wifiDetector = [RAReachabilityDetector newDetectorForLocalWiFi];

then implement the delegate method:

	- (void) reachabilityDetectorDidUpdateState:(RAReachabilityDetector *)detector {
	
		if (detector == _wifiDetector) {
		
			BOOL wifiReachableDirectly = WASCNetworkReachableDirectly(detector.networkStateFlags);
			
			//	…
		
		}
	
	}

You can invoke `-initWithAddress:` and pass a socket address, or `-initWithURL:` and pass an `NSURL`.  Or, you can simply pass a `SCNetworkReachabilityRef` to `-initWithReachabilityRef:`, in all cases the class does the right thing and lets you know about the changes.

Since merely knowing if the networking layer works is only half the battle, there is also `RAPulseCheckingReachabilityDetector`.  If you subclass it, and override `-executePulseCheckingBlockWithCallback:`, you have a chance to do additional work (networking, for example) and communicate with the application layer to see if it is suitable for processing more requests.

The class supports `-compare:` fully, so you can also hold several detectors in an `NSArray`, and sort them by availability.


## Licensing

This project is in the public domain.  You can use it and embed it in whatever application you sell, and you can use it for evil.  However, it is appreciated if you provide attribution, by linking to the project page ([https://github.com/evadne/RAReachability](https://github.com/evadne/RAReachability)) from your application.


## Credits

*	[Evadne Wu](http://twitter.com/evadne) at Radius ([Info](http://radi.ws))

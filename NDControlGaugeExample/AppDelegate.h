//
//  AppDelegate.h
//  NDControlGaugeExample
//
//  Created by Eric Yim on 11-09-16.
//  Copyright N/A 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

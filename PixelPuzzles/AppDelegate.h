//
//  AppDelegate.h
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/4/11.
//  Copyright Bauerkraut 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

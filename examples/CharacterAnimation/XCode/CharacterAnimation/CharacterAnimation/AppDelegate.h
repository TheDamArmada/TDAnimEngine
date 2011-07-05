//
//  AppDelegate.h
//  CharacterAnimation
//
//  Created by Jordi Martinez on 7/5/11.
//  Copyright Wieden + Kennedy 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

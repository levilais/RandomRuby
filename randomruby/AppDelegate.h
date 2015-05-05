//
//  AppDelegate.h
//  RandomRuby
//
//  Created by BrightSun on 8/29/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "Global.h"
#import "MKiCloudSync.h"

@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HomeViewController *viewController;
@property (nonatomic, retain) UINavigationController *navController;

@end

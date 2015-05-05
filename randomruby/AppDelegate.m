//
//  AppDelegate.m
//  RandomRuby
//
//  Created by BrightSun on 8/29/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "AppDelegate.h"
#import <RevMobAds/RevMobAds.h>
#import "Flurry.h"
#import <FacebookSDK/FacebookSDK.h>

//#define FB_APP_ID @"688456211173215"
//
//#define FB_ACCESS_TOKEN_KEY @"fb_access_token"
//#define FB_EXPIRATION_DATE_KEY @"fb_expiration_date"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // iCloud
    if ([MKiCloudSync start] < 0) {
        g_bEnablediCloud = NO;
    } else {
        g_bEnablediCloud = YES;
    }
    
    // Register RevMob
    [RevMobAds startSessionWithAppID:@"52b079cbb0333ec2f2000068"];
    
    // Register Flurry
    [Flurry setCrashReportingEnabled:true];
    [Flurry startSession:@"2229VJ79R3H9RVRT5V9W"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];

    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    initGameInfo();

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    saveGameInfo();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    loadSettingFromiCloud();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[FBSession activeSession] handleDidBecomeActive];
    loadSettingFromiCloud();
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSession activeSession] handleOpenURL:url];
}


@end

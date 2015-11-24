//
//  AppDelegate.m
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "AppDelegate.h"
#import "TBCrashKit.h"
#import "SqlService.h"
#import "TBCrashTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [TBCrashKit crash];
//    NSArray *array = [[NSArray alloc] init];
//    array[10];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TBCrashTableViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

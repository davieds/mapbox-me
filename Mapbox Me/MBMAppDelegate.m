//
//  MBMAppDelegate.m
//  Mapbox Me
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import "MBMAppDelegate.h"

#import "MBMViewController.h"

@implementation MBMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:[[MBMViewController alloc] initWithNibName:nil bundle:nil]];
    
    self.window.rootViewController = wrapper;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
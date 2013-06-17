//
//  DKAppDelegate.m
//  LiveBlur
//
//  Created by Dmitry Klimkin on 16/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKMainViewController.h"

@implementation DKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set Navigation Bar style
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"menu-bar"] forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor: [UIColor clearColor]];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment: 1.0f forBarMetrics: UIBarMetricsDefault];
    
    UIColor *titleColor = [UIColor colorWithRed: 150.0f/255.0f green: 149.0f/255.0f blue: 149.0f/255.0f alpha: 1.0f];
    UIColor* shadowColor = [UIColor colorWithWhite: 1.0 alpha: 1.0];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeTextColor: titleColor,
                                     UITextAttributeFont: [UIFont boldSystemFontOfSize: 23.0f],
                          UITextAttributeTextShadowColor: shadowColor,
                         UITextAttributeTextShadowOffset: [NSValue valueWithCGSize: CGSizeMake(0.0, 1.0)]}];
    
    self.window = [[UIWindow alloc] initWithFrame: ScreenRect];

    DKMainViewController *viewController = [[DKMainViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: viewController];
    
    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

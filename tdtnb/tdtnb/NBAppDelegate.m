//
//  NBAppDelegate.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBAppDelegate.h"


@implementation NBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.window.frame];
    if(CGRectGetHeight(self.window.frame)>480){
        _imageView.image = [UIImage imageNamed:@"启动页568"];
    }else{
        _imageView.image = [UIImage imageNamed:@"启动页480"];
    }
    [self.window addSubview:_imageView];
    [self.window makeKeyAndVisible];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerFireMethod) userInfo:nil repeats:NO];
    return YES;
}

- (void)timerFireMethod{
    [_imageView removeFromSuperview];
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; 
    _mapViewController = [[NBMapViewController alloc] initWithNibName:@"NBMapViewController" bundle:nil];
    _navController = [[UINavigationController alloc] init];
    [_navController setNavigationBarHidden:YES];
    [_navController pushViewController:_mapViewController animated:YES];
    [self.window setRootViewController:_navController];
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

//
//  NBAppDelegate.h
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBMapViewController.h"

@interface NBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NBMapViewController *mapViewController;
@property (strong, nonatomic) UINavigationController *navController;  

@end

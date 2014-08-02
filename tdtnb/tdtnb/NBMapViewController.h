//
//  NBMapViewController.h
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGSGoogleMapLayer.h"

@interface NBMapViewController : UIViewController<UITabBarDelegate>

@property (nonatomic, strong) IBOutlet UITabBar *bar;
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSGoogleMapLayer *tileMapLayer;
@property (nonatomic, strong) AGSGoogleMapLayer *wmsMapLayer;
@end

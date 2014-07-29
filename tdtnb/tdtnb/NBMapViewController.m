//
//  NBMapViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBMapViewController.h"
#import "NBNearSearchViewController.h"
#import "NBLineServiceViewController.h"
#import "NBFavoritesViewController.h"
#import "NBToolView.h"

@interface NBMapViewController ()<toolDelegate>

@property(nonatomic,strong) NBNearSearchViewController *nearSearchViewController;
@property(nonatomic,strong) NBLineServiceViewController *lineServiceViewController;
@property(nonatomic,strong) NBFavoritesViewController *favoritesViewController;
@property(nonatomic,strong) NBToolView *toolView;

@end

@implementation NBMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bar.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma  mark -  Action

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    self.toolView.hidden = YES;
    switch (item.tag) {
        case 1001:
        {
            [self.navigationController pushViewController:self.nearSearchViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
            break;
        case 1002:
        {
            [self.navigationController pushViewController:self.lineServiceViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
            break;
        case 1003:
        {
            [self.navigationController pushViewController:self.favoritesViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
            break;
        case 1004:
        {
            self.toolView.hidden = NO;
            [self.view addSubview:self.toolView];
        }
            break;
            
        default:
            break;
    }
    
}

- (NBNearSearchViewController *)nearSearchViewController{
    if(!_nearSearchViewController){
        _nearSearchViewController = [[NBNearSearchViewController alloc] initWithNibName:@"NBNearSearchViewController" bundle:nil];
    }
    return _nearSearchViewController;
}

- (NBLineServiceViewController *)lineServiceViewController{
    if(!_lineServiceViewController){
        _lineServiceViewController = [[NBLineServiceViewController alloc] initWithNibName:@"NBLineServiceViewController" bundle:nil];
    }
    return _lineServiceViewController;
}
- (NBFavoritesViewController *)favoritesViewController{
    if(!_favoritesViewController){
        _favoritesViewController = [[NBFavoritesViewController alloc] initWithNibName:@"NBFavoritesViewController" bundle:nil];
    }
    return _favoritesViewController;
}
- (NBToolView *)toolView{
    if(!_toolView){
        _toolView = [[NBToolView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-49-70, CGRectGetWidth(self.view.frame), 70)];
        _toolView.delegate = self;
        
    }
    return _toolView;
}

#pragma mark - toolDelegate
- (void)toolButtonClick:(int)buttonTag{
    switch (buttonTag) {
        case 100:
        {
            
        }
            break;
        case 101:
        {
            
            
        }
            break;
            
        case 102:
        {
            
            
        }
            break;
            
        case 103:
        {
            
            
        }
            break;
            
        case 104:
        {
            
            
        }
            break;
        case 105:
        {
            
            
        }
            break;
            
        default:
            break;
    }
}
@end

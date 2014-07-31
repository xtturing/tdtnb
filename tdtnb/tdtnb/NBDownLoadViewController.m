//
//  NBDownLoadViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-31.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBDownLoadViewController.h"
#import "NBDownLoadManagerViewController.h"

@interface NBDownLoadViewController ()

@end

@implementation NBDownLoadViewController

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.title = @"离线地图";
    
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    voiceBtn.frame = CGRectMake(0, 0, 80, 40);
    voiceBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [voiceBtn setTitle:@"下载管理" forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(downloadManager) forControlEvents:UIControlEventTouchUpInside];
    
    voiceBtn.enabled = NO;
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:voiceBtn];
    self.navigationItem.rightBarButtonItem = right;
    // Do any additional setup after loading the view from its nib.
}

- (void)downloadManager{
    NBDownLoadManagerViewController *manager = [[NBDownLoadManagerViewController alloc]initWithNibName:@"NBDownLoadManagerViewController" bundle:nil];
    [self.navigationController pushViewController:manager animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

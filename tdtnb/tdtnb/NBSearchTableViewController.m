//
//  NBSearchTableViewController.m
//  tdtnb
//
//  Created by xtturing on 14-8-5.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSearchTableViewController.h"
#import "NBSearch.h"
#import "dataHttpManager.h"
#import "SVProgressHUD.h"

#define REGION @"无锡"
#define RADIUS 3000
#define PAGESIZE 10
#define PAGENUM  0

@interface NBSearchTableViewController ()<dataHttpDelegate>
@property(nonatomic,strong) NSMutableArray *tableList;
@property(nonatomic,assign) int pageNum;
@property(nonatomic,assign) int pageSize;
@end

@implementation NBSearchTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [dataHttpManager getInstance].delegate = self;
    [self doSearch];
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    _tableList = [[NSMutableArray alloc] initWithCapacity:10];
    _pageNum = PAGENUM;
    _pageSize = PAGESIZE;
    self.navigationItem.title = self.searchText;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NBSearch *searchItem = [_tableList objectAtIndex:indexPath.row];
    static NSString *reuseIdetify = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = searchItem.name;
    cell.imageView.image = [UIImage imageNamed:@"gpscenterpoint"];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tableList count];
}
#pragma mark -dataHttpDelegate

-(void)doSearch{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_searchType == AFKeySearch){
            [[dataHttpManager getInstance] letDoSearchWithQuery:self.searchText region:REGION searchType:1 pageSize:_pageSize pageNum:_pageNum];
        }
        if(_searchType == AFRadiusSearch){
            [[dataHttpManager getInstance] letDoRadiusSearchWithQuery:self.searchText location:self.location radius:RADIUS scope:1 pageSize:_pageSize pageNum:_pageNum];
        }
        
    });
}

- (void)didGetFailed{
   [SVProgressHUD dismiss];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"天地图宁波" message:@"查询发生异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [view show];
}

-(void)didGetSearchList:(NSArray *)searchList{
    [SVProgressHUD dismiss];
    [_tableList addObjectsFromArray:searchList];
    [self.tableView reloadData];
}

-(void)didGetRadiusSearchList:(NSArray *)radiusList{
    [SVProgressHUD dismiss];
    [_tableList addObjectsFromArray:radiusList];
    [self.tableView reloadData];
}

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

- (void)addItem {
    // Add a new time
    _pageNum +=1;
    [self doSearch];
    [self stopLoading];
}


@end

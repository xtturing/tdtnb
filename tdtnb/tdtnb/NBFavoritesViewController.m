//
//  NBFavoritesViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBFavoritesViewController.h"
#import "NBSearch.h"
#import "NBSearchDetailViewController.h"
@interface NBFavoritesViewController (){
    UISegmentedControl *segment;
}

@property (nonatomic,strong) NSArray *favoritePoints;
@property (nonatomic,strong) NSArray *favoriteLines;

@end

@implementation NBFavoritesViewController

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
    self.navigationItem.title = @"返回";
    segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"收藏的点",@"收藏路线", nil]];
    segment.frame = CGRectMake(0, 7, 140, 30);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = segment;
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    self.navigationItem.rightBarButtonItem = right;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _favoritePoints = [NSArray arrayWithArray:[defaults objectForKey:@"FAVORITES_POINT"]];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)editAction{
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]){
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
    }else{
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(segment.selectedSegmentIndex == 0){
        NSUInteger cou = [_favoritePoints count];
        if(cou){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        return cou;
    }else{
        NSUInteger cou = [_favoriteLines count];
        if(cou){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        return cou;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(segment.selectedSegmentIndex == 0){
        return 60;
    }else{
        return 120;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetify = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.numberOfLines = 0;
    if(segment.selectedSegmentIndex == 0){
        NBSearch *detail = [NSKeyedUnarchiver unarchiveObjectWithData:[_favoritePoints objectAtIndex:indexPath.row] ];
        cell.textLabel.text = detail.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"地址：%@",detail.address];
    }else{
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(segment.selectedSegmentIndex == 0){
        NBSearch *searchItem = [NSKeyedUnarchiver unarchiveObjectWithData:[_favoritePoints objectAtIndex:indexPath.row] ];
        if(searchItem){
            NBSearchDetailViewController *detailViewController = [[NBSearchDetailViewController alloc] initWithNibName:@"NBSearchDetailViewController" bundle:nil];
            detailViewController.detail = searchItem;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }else{
        
    }
 
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"完成"]){
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        if(segment.selectedSegmentIndex == 0 ){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *array = [NSMutableArray arrayWithArray:_favoritePoints];
                [array removeObjectAtIndex:indexPath.row];
                _favoritePoints = (NSArray *)array;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:_favoritePoints forKey:@"FAVORITES_POINT" ];
                [defaults synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            });
        }else{
            
        }
    }
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    
    [_tableView reloadData];
}

@end

//
//  NBNearSearchViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBNearSearchViewController.h"
#define Duration 0.2
@interface NBNearSearchViewController ()<UISearchBarDelegate>
{
    BOOL contain;
    CGPoint startPoint;
    CGPoint originPoint;
    
}
@property (strong , nonatomic) NSMutableArray *itemArray;
@property(nonatomic,strong) UISearchBar *searchBar;
@end

@implementation NBNearSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //导航条的搜索条
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,0.0f,180.0f,44.0f)];
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"宁波市政府"];
        float version = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
        if ([ _searchBar respondsToSelector : @selector (barTintColor)]) {
            float  iosversion7_1 = 7.1 ;
            if (version >= iosversion7_1)
            {//iOS7.1
                [[[[ _searchBar.subviews objectAtIndex : 0 ] subviews] objectAtIndex: 0 ] removeFromSuperview];
                
                [ _searchBar setBackgroundColor:[ UIColor clearColor]];
            }
            else
            {
                //iOS7.0
                [ _searchBar setBarTintColor :[ UIColor clearColor ]];
                [ _searchBar setBackgroundColor :[ UIColor clearColor ]];
            }
        }
        else
        {
            //iOS7.0 以下
            [[ _searchBar.subviews objectAtIndex: 0 ] removeFromSuperview ];
            [ _searchBar setBackgroundColor:[ UIColor clearColor ]];
        }
        
        //将搜索条放在一个UIView上
        UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        searchView.backgroundColor = [UIColor clearColor];
        [searchView addSubview:_searchBar];
        
        self.navigationItem.titleView = searchView;
        
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(0, 0, 44, 40);
        [voiceBtn setImage:[UIImage imageNamed:@"icon_mircophone2"] forState:UIControlStateNormal];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:voiceBtn];
        self.navigationItem.rightBarButtonItem = right;
        
        UIButton *hiddenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2)];
        [hiddenBtn setBackgroundColor:[UIColor clearColor]];
        [hiddenBtn addTarget:self action:@selector(hiddenKeyBord) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:hiddenBtn];
        
        for (NSInteger i = 0;i<16;i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",49+i]];
            btn.frame = CGRectMake(20+(i%4)*75, 60+(i/4)*75, image.size.width/2.5, image.size.height/2.5);
            btn.userInteractionEnabled = YES;
            btn.tag = i;
            [btn setImage:image forState:UIControlStateNormal];
             [btn setImage:image forState:UIControlStateHighlighted];
            [self.imageView addSubview:btn];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
            [btn addGestureRecognizer:longGesture];
            [self.itemArray addObject:btn];
            
        }


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hiddenKeyBord{
    [_searchBar resignFirstResponder];
}
- (void)buttonLongPressed:(UILongPressGestureRecognizer *)sender
{
    
    UIButton *btn = (UIButton *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startPoint = [sender locationInView:sender.view];
        originPoint = btn.center;
        [UIView animateWithDuration:Duration animations:^{
            
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            btn.alpha = 0.7;
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX = newPoint.x-startPoint.x;
        CGFloat deltaY = newPoint.y-startPoint.y;
        btn.center = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
        //NSLog(@"center = %@",NSStringFromCGPoint(btn.center));
        NSInteger index = [self indexOfPoint:btn.center withButton:btn];
        if (index<0)
        {
            contain = NO;
        }
        else
        {
            [UIView animateWithDuration:Duration animations:^{
                
                CGPoint temp = CGPointZero;
                UIButton *button = _itemArray[index];
                temp = button.center;
                button.center = originPoint;
                btn.center = temp;
                originPoint = btn.center;
                contain = YES;
                
            }];
        }
        
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:Duration animations:^{
            
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1.0;
            if (!contain)
            {
                btn.center = originPoint;
            }
        }];
    }
}


- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIButton *)btn
{
    for (NSInteger i = 0;i<_itemArray.count;i++)
    {
        UIButton *button = _itemArray[i];
        if (button != btn)
        {
            if (CGRectContainsPoint(button.frame, point))
            {
                return i;
            }
        }
    }
    return -1;
}

@end

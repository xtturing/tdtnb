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
#import "NBDownLoadViewController.h"
#import "SpeechToTextModule.h"
#import "Reachability.h"
#import "NBSearch.h"
#import "NBSearchTableViewController.h"

//contants for data layers
#define kTiledNB @"http://183.136.157.100:10087/wmts/nbmapall?service=WMTS&request=GetTile&version=1.0.0&layer=0&style=default&tileMatrixSet=nbmap&format=image/png&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d"
#define KTiledTDT @"http://t0.tianditu.com/vec_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"

#define kWMSNB  @"http://183.136.157.100:10087/wmts/nbmapall?service=WMTS&request=GetTile&version=1.0.0&layer=0&style=default&tileMatrixSet=nbmap&format=image/png&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d"
#define kWMSTDT  @"http://t0.tianditu.com/img_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"

#define kDynamicNB @"http://www.nbmap.gov.cn/ArcGIS/rest/services/nbdxx/MapServer"

@interface NBMapViewController ()<toolDelegate,UISearchBarDelegate,AGSMapViewLayerDelegate,SpeechToTextModuleDelegate>{
    UITextField *fakeTextField;
}

@property(nonatomic,strong) NBNearSearchViewController *nearSearchViewController;
@property(nonatomic,strong) NBLineServiceViewController *lineServiceViewController;
@property(nonatomic,strong) NBFavoritesViewController *favoritesViewController;
@property(nonatomic,strong) NBToolView *toolView;
@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) UIButton *hiddenBtn;
@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;

@end

@implementation NBMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //导航条的搜索条
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,0.0f,240.0f,44.0f)];
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"如:宁波市政府"];
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
        for(id cc in [_searchBar subviews]){
            if([cc isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)cc;
                [btn setTitle:@"取消"  forState:UIControlStateNormal];
            }  
        }
        //将搜索条放在一个UIView上
        UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        searchView.backgroundColor = [UIColor clearColor];
        [searchView addSubview:_searchBar];
        
        self.navigationItem.titleView = searchView;
        
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(0, 0, 44, 40);
        [voiceBtn setImage:[UIImage imageNamed:@"icon_mircophone2"] forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(speechToText) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:voiceBtn];
        self.navigationItem.rightBarButtonItem = right;
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    
    fakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [fakeTextField setHidden:NO];
    [self.view addSubview:fakeTextField];
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
    
    self.navigationItem.title = @"返回";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.bar.delegate = self;
    self.mapView.layerDelegate = self;
    _tileMapLayer=[[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:kTiledNB tdPath:KTiledTDT envelope:[AGSEnvelope envelopeWithXmin:119.49 ymin:35.522 xmax:121.032  ymax:37.164  spatialReference:self.mapView.spatialReference] level:@"9"];
	[self.mapView addMapLayer:_tileMapLayer withName:@"tiledLayer"];
    [self.mapView bringSubviewToFront:self.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma  mark -  Action

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [_toolView removeFromSuperview];
    switch (item.tag) {
        case 1001:
        {
            [self.navigationController pushViewController:self.nearSearchViewController animated:YES];
        }
            break;
        case 1002:
        {
            [self.navigationController pushViewController:self.lineServiceViewController animated:YES];
        }
            break;
        case 1003:
        {
            [self.navigationController pushViewController:self.favoritesViewController animated:YES];
        }
            break;
        case 1004:
        {
            [self.mapView addSubview:self.toolView];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)hiddenKeyBord{
    [_searchBar resignFirstResponder];
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
            NBDownLoadViewController *down = [[NBDownLoadViewController alloc] initWithNibName:@"NBDownLoadViewController" bundle:nil];
            [self.navigationController pushViewController:down animated:YES];
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
            [self snopShot];
            
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
#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    
	// comment to disable the GPS on start up
	[self.mapView.gps start];
}

- (void)snopShot{
    //支持retina高分的关键
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(_mapView.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(_mapView.frame.size);
    }
    
    //获取图像
    [_mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIGraphicsEndImageContext();
    [self showMessageWithAlert:@"图片已保存到本地相册"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
     [self.view addSubview:self.hiddenBtn];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    [_hiddenBtn removeFromSuperview];
   
}

-(UIButton *)hiddenBtn{
    if(!_hiddenBtn){
        _hiddenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-200)];
        [_hiddenBtn setBackgroundColor:[UIColor clearColor]];
        [_hiddenBtn addTarget:self action:@selector(hiddenKeyBord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenBtn;
}

#pragma  mark -speechToText

-(void)speechToText{
    [self.speechToTextObj beginRecording];
}

#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"responseString: %@",responseString);
    return YES;
}
- (void)showSineWaveView:(SineWaveViewController *)view
{
    [fakeTextField setInputView:view.view];
    [fakeTextField becomeFirstResponder];
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    [fakeTextField resignFirstResponder];
}
- (void)showLoadingView
{
    NSLog(@"show loadingView");
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}

#pragma mark -reachability

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        if(![reach isReachableViaWiFi]){
            
        }else{
            
        }
    }
    else
    {
        [self showMessageWithAlert:@"网络链接断开"];
    }
}

#pragma mark - UIAlertView

- (void)showMessageWithAlert:(NSString *)message{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"天地图宁波" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [view show];
}

#pragma mark -UISearchBarDelegate

//点击键盘上的search按钮时调用

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar

{
    [searchBar resignFirstResponder];
    NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
    searchViewController.searchText = searchBar.text;
    searchViewController.searchType = AFKeySearch;
    [self.navigationController pushViewController:searchViewController animated:YES];
    
}


//cancel按钮点击时调用

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar

{
    
    searchBar.text = @"";

    [searchBar resignFirstResponder];
    
}



@end

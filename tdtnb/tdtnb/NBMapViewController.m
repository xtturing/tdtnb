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
#import "CLLocation+Sino.h"
#import "NBSearchDetailViewController.h"
#import "dataHttpManager.h"

//contants for data layers
#define kTiledNB @"http://60.190.2.120/wmts/nbmapall?service=WMTS&request=GetTile&version=1.0.0&layer=0&style=default&tileMatrixSet=nbmap&format=image/png&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d"
#define KTiledTDT @"http://t0.tianditu.com/vec_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"
#define KTiledTDTLabel  @"http://t0.tianditu.com/cva_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"

#define kWMSNB  @"http://60.190.2.120:10089/wmts/nbrmapall?service=WMTS&request=GetTile&version=1.0.0&layer=0&style=default&tileMatrixSet=nbmap&format=image/jpeg&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d"
#define kWMSTDT  @"http://t0.tianditu.com/img_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"
#define KWMSTDTLabel @"http://t0.tianditu.com/cia_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"

#define kDynamicNB @"http://www.nbmap.gov.cn/ArcGIS/rest/services/nbdxx/MapServer"

@interface NBMapViewController ()<toolDelegate,UISearchBarDelegate,AGSMapViewLayerDelegate,SpeechToTextModuleDelegate,AGSInfoTemplateDelegate,dataHttpDelegate>{
    UITextField *fakeTextField;
    double _distance;
    double _area;
    AGSSRUnit _distanceUnit;
    AGSAreaUnits _areaUnit;
    AGSPoint *errorPoint;
    int errorScale;
}

@property(nonatomic,strong) NBNearSearchViewController *nearSearchViewController;
@property(nonatomic,strong) NBLineServiceViewController *lineServiceViewController;
@property(nonatomic,strong) NBFavoritesViewController *favoritesViewController;
@property(nonatomic,strong) NBToolView *toolView;
@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) UIButton *hiddenBtn;
@property(nonatomic,strong) UITextView *textView;
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
     self.mapView.calloutDelegate=self;
    [self addTileLayer];
    [self zooMapToLevel:13 withCenter:[AGSPoint pointWithX:121.55629730245123 y:29.874820709509887 spatialReference:self.mapView.spatialReference]];
    // Do any additional setup after loading the view from its nib.
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsPointInMap:) name:@"SearchDetailGPSPoint" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchPointsInMap:) name:@"searchPointsInMap" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dataHttpManager getInstance].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if(self.mapView.gps.enabled){
        [self.mapView.gps stop];
    }
}
#pragma  mark -  Action

- (void)addTileLayer{
    if(_wmsMapLayer){
        [self.mapView removeMapLayerWithName:@"wmsLayer"];
        [self.mapView removeMapLayerWithName:@"wmsLabelLayer"];
        _wmsMapLayer = nil;
    }
    _tileMapLayer=[[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:kTiledNB tdPath:KTiledTDT envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"9"];
	[self.mapView insertMapLayer:_tileMapLayer withName:@"tiledLayer" atIndex:0];
    AGSGoogleMapLayer *tileLabelLayer = [[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:nil tdPath:KTiledTDTLabel envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"9"];
    [self.mapView insertMapLayer:tileLabelLayer withName:@"tiledLabelLayer" atIndex:1];
}

- (void)addWMSLayer{
    if (_tileMapLayer) {
        [self.mapView removeMapLayerWithName:@"tiledLayer"];
        [self.mapView removeMapLayerWithName:@"tiledLabelLayer"];
        _tileMapLayer = nil;
    }
    _wmsMapLayer=[[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:kWMSNB tdPath:kWMSTDT envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"18"];
	[self.mapView insertMapLayer:_wmsMapLayer withName:@"wmsLayer" atIndex:0];
    AGSGoogleMapLayer *wmsLabelLayer = [[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:nil tdPath:KWMSTDTLabel envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"18"];
    [self.mapView insertMapLayer:wmsLabelLayer withName:@"wmsLabelLayer" atIndex:1];
}

- (void)zooMapToLevel:(int)level withCenter:(AGSPoint *)point{
    AGSGoogleMapLayer *layer = (AGSGoogleMapLayer *)[self.mapView.mapLayers objectAtIndex:0];
    AGSLOD *lod = [layer.tileInfo.lods objectAtIndex:level];
    [self.mapView zoomToResolution:lod.resolution withCenterPoint:point animated:YES];
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [_toolView removeFromSuperview];
    self.sketchLayer = nil;
    self.sketchLayer.geometry = nil;
    self.mapView.touchDelegate = nil;
    [self.mapView removeMapLayerWithName:@"sketchLayer"];
    [self.mapView.callout removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
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
            self.sketchLayer = [AGSSketchGraphicsLayer graphicsLayer];
            self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
            [self.mapView addMapLayer:self.sketchLayer withName:@"sketchLayer"];
            self.mapView.touchDelegate = self.sketchLayer;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:@"GeometryChanged" object:nil];
            // Set the default measures and units
            _distance = 0;
            _area = 0;
            _distanceUnit = AGSSRUnitKilometer;
            _areaUnit = AGSAreaUnitsSquareKilometers;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)hiddenKeyBord{
    [_searchBar resignFirstResponder];
    if (_textView) {
        [_textView resignFirstResponder];
    }
}

#pragma mark -IBAction

-(IBAction)gps:(id)sender{
    if(self.mapView.gps.enabled){
        [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
    }else {
        UIAlertView *alert;
        alert = [[UIAlertView alloc]
                 initWithTitle:@"天地图宁波"
                 message:@"请开启GPS使用你的位置信息"
                 delegate:nil cancelButtonTitle:nil
                 otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
}
-(IBAction)list:(id)sender{
    if(_searchBar.text.length>0){
        NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
        searchViewController.searchText = _searchBar.text;
        searchViewController.searchType = AFKeySearch;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }else{
        UIAlertView *alert;
        alert = [[UIAlertView alloc]
                 initWithTitle:@"天地图宁波"
                 message:@"请在查询框输入关键字"
                 delegate:nil cancelButtonTitle:nil
                 otherButtonTitles:@"确定", nil];
        [alert show];
    }

}
-(IBAction)prev:(id)sender{
    
}
-(IBAction)next:(id)sender{
    
}
-(IBAction)changeMap:(id)sender{
    AGSGoogleMapLayer *layer = [self.mapView.mapLayers objectAtIndex:0];
    if([layer.name isEqualToString:@"tiledLayer"]){
        [self addWMSLayer];
    }else{
        [self addTileLayer];
    }
}
-(IBAction)singleLine:(id)sender{
    if(!_dynamicMapLayer){
        _dynamicMapLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:[NSURL URLWithString:kDynamicNB]];
        [self.mapView addMapLayer:_dynamicMapLayer withName:@"dynamicMapLayer"];
    }else{
        [self.mapView removeMapLayerWithName:@"dynamicMapLayer"];
        _dynamicMapLayer = nil;
    }
}
-(IBAction)zoomIn:(id)sender{
    [self.mapView zoomIn:YES];
}
-(IBAction)zoomOut:(id)sender{
    [self.mapView zoomOut:YES];
}

- (void)gpsPointInMap:(NSNotification *)notic{
    NBSearch *detail = [notic.userInfo objectForKey:@"detail"];
    AGSPictureMarkerSymbol * dian = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"gpscenterpoint"];
    AGSPoint *point =	[AGSPoint pointWithX:[[detail.location objectForKey:@"lng"] floatValue]  y: [[detail.location objectForKey:@"lat"] floatValue] spatialReference:nil];
    if(point.x == 0 || point.y == 0 ){
        return;
    }
    NSArray *tipkey=[[NSArray alloc]initWithObjects:@"detail",@"title",@"object",nil];
    NSArray *tipvalue=[[NSArray alloc]initWithObjects:detail.address,detail.name,detail,nil];
    NSMutableDictionary * tips=[[NSMutableDictionary alloc]initWithObjects:tipvalue forKeys:tipkey];
    AGSGraphic * pointgra= nil;
    pointgra = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:tips infoTemplateDelegate:self];
    dian.yoffset=16;
    pointgra.symbol = dian;
    [self.graphicsLayer addGraphic:pointgra];
    self.mapView.callout.customView = nil;
    self.mapView.callout.title = detail.name;
    self.mapView.callout.detail = detail.address;
    self.mapView.callout.titleColor=[UIColor whiteColor];
    self.mapView.callout.autoAdjustWidth=YES;
    self.mapView.callout.cornerRadius=2;
    self.mapView.callout.accessoryButtonHidden = NO;
    self.mapView.callout.accessoryButtonImage = [UIImage imageNamed:@"b3.png"];
    
    [self.mapView showCalloutAtPoint:point forGraphic:pointgra animated:YES];
    
    [self.mapView centerAtPoint:point animated:YES];
    [self.graphicsLayer dataChanged];
}

-(void)searchPointsInMap:(NSNotification *)notic{
    [self.graphicsLayer removeAllGraphics];
    
    NSMutableArray *searchList = [notic.userInfo objectForKey:@"searchList"];
    for (NBSearch *detail in searchList) {
        AGSGraphic * pointgra= nil;
        AGSPoint *point =	[AGSPoint pointWithX:[[detail.location objectForKey:@"lng"] floatValue]  y: [[detail.location objectForKey:@"lat"] floatValue] spatialReference:nil];
        if(point.x == 0 || point.y == 0 ){
            return;
        }
        NSArray *tipkey=[[NSArray alloc]initWithObjects:@"detail",@"title",@"object",nil];
        NSArray *tipvalue=[[NSArray alloc]initWithObjects:detail.address,detail.name,detail,nil];
        NSMutableDictionary * tips=[[NSMutableDictionary alloc]initWithObjects:tipvalue forKeys:tipkey];
        
        AGSPictureMarkerSymbol * dian = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"point"];
        pointgra = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:tips infoTemplateDelegate:self];
        dian.yoffset=19;
        pointgra.symbol = dian;
        [self.graphicsLayer addGraphic:pointgra];
        [self.graphicsLayer dataChanged];
        [self zooMapToLevel:10 withCenter:point];
    }
}

#pragma mark -init

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
            self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
            
        }
            break;
            
        case 102:
        {
            self.sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
            
        }
            break;
            
        case 103:
        {
            [self snopShot];
            
        }
            break;
            
        case 104:
        {
            self.sketchLayer.geometry = [[AGSMutablePoint alloc] initWithSpatialReference:self.mapView.spatialReference];
        }
            break;
        case 105:
        {
            [self.sketchLayer clear];
            [self.mapView.callout removeFromSuperview];
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
    if(_searchBar.text.length>0){
        NBSearchTableViewController *searchViewController = [[NBSearchTableViewController alloc] init];
        searchViewController.searchText = _searchBar.text;
        searchViewController.searchType = AFKeySearch;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
    
}


//cancel按钮点击时调用

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar

{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
}


#pragma mark -measure

- (void)respondToGeomChanged:(NSNotification*)notification {
    
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    
    // Update the distance and area whenever the geometry changes
    if ([sketchGeometry isKindOfClass:[AGSMutablePolyline class]]) {
        [self updateDistance:_distanceUnit];
    }
    else if ([sketchGeometry isKindOfClass:[AGSMutablePolygon class]]){
        [self updateArea:_areaUnit];
    }else if ([sketchGeometry isKindOfClass:[AGSMutablePoint class]]){
        [self errorRecovery];
    }
   
}

- (void)updateDistance:(AGSSRUnit)unit {
    
    // Get the sketch layer's geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    // Get the geodesic distance of the current line
    _distance = [geometryEngine geodesicLengthOfGeometry:sketchGeometry inUnit:_distanceUnit];
    if(_distance == 0){
        self.toolView.label.text = @"请在地图上点击画线测量距离";
    }else{
        self.toolView.label.text = [NSString stringWithFormat:@"距离：%.2f 公里", _distance];
    }
}

- (void)updateArea:(AGSAreaUnits)unit {
    
    // Get the sketch layer's geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    // Get the area of the current polygon
    _area = [geometryEngine shapePreservingAreaOfGeometry:sketchGeometry inUnit:_areaUnit];
    if(_area == 0){
        self.toolView.label.text = @"请在地图上点击画面测量面积";
    }else{
        self.toolView.label.text = [NSString stringWithFormat:@"面积：%.4f 平方公里", _area];
    }
}

- (void)errorRecovery{
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    if ([sketchGeometry isKindOfClass:[AGSMutablePoint class]] && sketchGeometry.isValid){
        errorPoint = (AGSPoint *)sketchGeometry;
        AGSGoogleMapLayer *layer = (AGSGoogleMapLayer *)[self.mapView.mapLayers objectAtIndex:0];
        for(AGSLOD *lod in layer.tileInfo.lods){
            if(lod.resolution == self.mapView.resolution){
                errorScale = lod.level;
                break;
            }
        }
        self.mapView.callout.customView = self.textView;
        [self.mapView showCalloutAtPoint:errorPoint];
    }
}

- (UITextView *)textView{
    if(!_textView){
        _textView =[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 120, 60)];
        _textView.text = @"请输入纠错内容...";
        _textView.delegate = self;
        _textView.textColor = [UIColor grayColor];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.scrollEnabled = YES;
    }
    return _textView;
}

#pragma mark - AGSMapViewCalloutDelegate

- (BOOL)mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic{
    if([[graphic.attributes objectForKey:@"object"] isKindOfClass:[NBSearch class]]){
        NBSearch *detail = (NBSearch *)[graphic.attributes objectForKey:@"object"];
        self.mapView.callout.customView = nil;
        self.mapView.callout.title = detail.name;
        self.mapView.callout.detail = detail.address;
        self.mapView.callout.titleColor=[UIColor whiteColor];
        self.mapView.callout.autoAdjustWidth=YES;
        self.mapView.callout.cornerRadius=2;
        self.mapView.callout.accessoryButtonHidden = NO;
        self.mapView.callout.accessoryButtonImage = [UIImage imageNamed:@"b3.png"];
    }
    return YES;
}
- (void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic{
    
    if([[graphic.attributes objectForKey:@"object"] isKindOfClass:[NBSearch class]]){
        NBSearchDetailViewController *detailViewController = [[NBSearchDetailViewController alloc] initWithNibName:@"NBSearchDetailViewController" bundle:nil];
        detailViewController.detail = [graphic.attributes objectForKey:@"object"];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textView.text = @"";
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendErrorRecovery];
        return NO;
    }
    if (range.location>=100)
    {
        return  NO;
    }
    else
    {
        return YES;   
    }   
}

- (void)sendErrorRecovery{
    if(_textView.text.length > 0 && errorScale > 0 && errorPoint.x != 0 && errorPoint.y != 0){
        [[dataHttpManager getInstance] letDoPostErrorWithMessage:_textView.text plottingScale:[NSString stringWithFormat:@"%d",errorScale] point:[NSString stringWithFormat:@"%f,%f",errorPoint.x,errorPoint.y]];
    }
}
#pragma mark 
- (void)didPostError:(NSString *)string{
    UIAlertView *alert;
    alert = [[UIAlertView alloc]
             initWithTitle:@"天地图宁波"
             message:string
             delegate:nil cancelButtonTitle:nil
             otherButtonTitles:@"确定", nil];
    [alert show];
    self.sketchLayer.geometry = nil;
    [self.sketchLayer removeAllGraphics];
    [self.mapView.callout removeFromSuperview];
}
@end

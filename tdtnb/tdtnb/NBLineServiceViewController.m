//
//  NBLineServiceViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBLineServiceViewController.h"
#import <CoreLocation/CoreLocation.h> 
#import "dataHttpManager.h"
#import "NBRoute.h"
#import "NBLine.h"

//contants for data layers
#define kTiledNB @"http://60.190.2.120/wmts/nbmapall?service=WMTS&request=GetTile&version=1.0.0&layer=0&style=default&tileMatrixSet=nbmap&format=image/png&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d"
#define KTiledTDT @"http://t0.tianditu.com/vec_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"
#define KTiledTDTLabel  @"http://t0.tianditu.com/cva_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=c&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=tiles"

@interface NBLineServiceViewController ()<AGSMapViewLayerDelegate,dataHttpDelegate>

@end

@implementation NBLineServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _segment.selectedSegmentIndex = 1;
    [_segment addTarget:self action:@selector(segmentStyleAction:) forControlEvents:UIControlEventValueChanged];
    [_segmentPoint addTarget:self action:@selector(segmentPointAction:) forControlEvents:UIControlEventValueChanged];
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"公交",@"自驾", nil]];
    seg.frame = CGRectMake(0, 7, 140, 30);
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]  initWithTitle:@"详情列表" style:UIBarButtonItemStylePlain target:self action:@selector(detailAction)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.mapView.layerDelegate = self;
	
	[self addTileLayer];
    [self zooMapToLevel:13 withCenter:[AGSPoint pointWithX:121.55629730245123 y:29.874820709509887 spatialReference:self.mapView.spatialReference]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [dataHttpManager getInstance].delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [dataHttpManager getInstance].delegate =  nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)detailAction{
    
}
- (void)addTileLayer{
    AGSGoogleMapLayer *tileMapLayer=[[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:kTiledNB tdPath:KTiledTDT envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"9"];
	[self.mapView insertMapLayer:tileMapLayer withName:@"tiledLayer" atIndex:0];
    AGSGoogleMapLayer *tileLabelLayer = [[AGSGoogleMapLayer alloc] initWithGoogleMapSchema:nil tdPath:KTiledTDTLabel envelope:[AGSEnvelope envelopeWithXmin:119.65171432515596 ymin:29.021148681921858 xmax:123.40354537984406  ymax:30.441131592078335  spatialReference:self.mapView.spatialReference] level:@"9"];
    [self.mapView insertMapLayer:tileLabelLayer withName:@"tiledLabelLayer" atIndex:1];
}
- (void)zooMapToLevel:(int)level withCenter:(AGSPoint *)point{
    AGSGoogleMapLayer *layer = (AGSGoogleMapLayer *)[self.mapView.mapLayers objectAtIndex:0];
    AGSLOD *lod = [layer.tileInfo.lods objectAtIndex:level];
    [self.mapView zoomToResolution:lod.resolution withCenterPoint:point animated:YES];
}

- (NSString *)pointToAddress:(CLLocation *)location{
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    __block NSString *address= nil;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemark,NSError *error)
     {
         CLPlacemark *mark=[placemark objectAtIndex:0];
         address = [NSString stringWithFormat:@"%@%@%@",mark.subLocality,mark.thoroughfare,mark.subThoroughfare];
     } ];
    return address;
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    if(Seg.selectedSegmentIndex == 0){
        [_segment setTitle:@"较快捷" forSegmentAtIndex:0];
        [_segment setTitle:@"少换乘" forSegmentAtIndex:1];
        [_segment setTitle:@"少步行" forSegmentAtIndex:2];
    }else{
        [_segment setTitle:@"最快线路" forSegmentAtIndex:0];
        [_segment setTitle:@"最短线路" forSegmentAtIndex:1];
        [_segment setTitle:@"少走高速" forSegmentAtIndex:2];
    }
    _segment.selectedSegmentIndex = 1;
}
-(void)segmentStyleAction:(UISegmentedControl *)Seg{
    
}
-(void)segmentPointAction:(UISegmentedControl *)Seg{
    [[dataHttpManager getInstance] letDoBusSearchWithStartposition:@"116.39846,39.89814" endposition:@"116.39022,39.89017" linetype:@"1"];
//    [[dataHttpManager getInstance] letDoLineSearchWithOrig:@"116.3599,40.08882" dest:@"116.44985,40.06308" style:@"0"];
}

#pragma -mark

-(void)didGetRoute:(NBRoute *)route{
    
}

- (void)didGetBusLines:(NSArray *)lineList{
    
}

@end

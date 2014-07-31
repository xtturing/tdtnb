//
//  NBLineServiceViewController.m
//  tdtnb
//
//  Created by xtturing on 14-7-27.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBLineServiceViewController.h"
//contants for data layers
#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
#define kDynamicMapServiceURL @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer"

@interface NBLineServiceViewController ()<AGSMapViewLayerDelegate>

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
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"公交",@"自驾", nil]];
    segment.frame = CGRectMake(0, 7, 140, 30);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = segment;
    
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    voiceBtn.frame = CGRectMake(0, 0, 80, 40);
    voiceBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [voiceBtn setTitle:@"详情列表" forState:UIControlStateNormal];
    
    voiceBtn.enabled = NO;
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:voiceBtn];
    self.navigationItem.rightBarButtonItem = right;
    
    self.mapView.layerDelegate = self;
	
	//create an instance of a tiled map service layer
	AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:kTiledMapServiceURL]];
	
	//Add it to the map view
	UIView<AGSLayerView>* lyr = [self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
    
	
	// Setting these two properties lets the map draw while still performing a zoom/pan
	lyr.drawDuringPanning = YES;
	lyr.drawDuringZooming = YES;
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:4326];
	double xmin, ymin, xmax, ymax;
	xmin = -125.33203125;
	ymin = -1.58203125;
	xmax = -69.08203125;
	ymax = 79.27734375;
	
	// zoom to the United States
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:sr];
	[self.mapView zoomToEnvelope:env animated:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  dataHttpManager.m
//  房伴
//
//  Created by tao xu on 13-8-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "dataHttpManager.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "NBSearch.h"

static dataHttpManager * instance=nil;
@implementation dataHttpManager

-(void)dealloc
{
    self.requestQueue = nil;
}
//单例
+(dataHttpManager*)getInstance{
    @synchronized(self) {
        if (instance==nil) {
            instance=[[dataHttpManager alloc] initWithDelegate];
            [instance start];
        }
    }
    return instance;
}
//初始化
- (id)initWithDelegate {
    self = [super init];
    if (self) {
        _requestQueue = [[ASINetworkQueue alloc] init];
        [_requestQueue setDelegate:self];
        [_requestQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [_requestQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [_requestQueue setRequestWillRedirectSelector:@selector(request:willRedirectToURL:)];
		[_requestQueue setShouldCancelAllRequestsOnFailure:NO];
        [_requestQueue setShowAccurateProgress:YES];
        
    }
    
    return self;
}
#pragma mark - Methods
- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(DataRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(DataRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																						  kCFAllocatorDefault, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8));
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}
#pragma mark - Http Operate
//获取当前区域列表
-(void)letDoSearchWithQuery:(NSString *)query region:(NSString *)region  searchType:(int)type  pageSize:(int)size pageNum:(int)num{
    NSString *q = [NSString stringWithFormat:@"%@",query];
    NSString *r = [NSString stringWithFormat:@"%@",region];
    NSString *s = [NSString stringWithFormat:@"%d",size];
    NSString *n = [NSString stringWithFormat:@"%d",num];
    NSMutableDictionary     *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:  q, @"query", r,  @"region",s,  @"page_size",n,  @"page_num",@"1",  @"scope",@"yMMBb6l8GBeG6GcHjnNuHVMy",  @"ak",@"json", @"output",nil];
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/find/get_area_list.aspx",HTTP_URL];
    NSURL  *url = [self generateURL:baseUrl params:params];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:AAGetSearchList];
    [_requestQueue addOperation:request];
}
//
-(void)letDoRadiusSearchWithQuery:(NSString *)query location:(NSString *)location  radius:(int)radius scope:(int)scope pageSize:(int)size pageNum:(int)num{
    
}
//继续添加

#pragma mark - Operate queue
- (BOOL)isRunning
{
	return ![_requestQueue isSuspended];
}

- (void)start
{
	if( [_requestQueue isSuspended] )
		[_requestQueue go];
}

- (void)pause
{
	[_requestQueue setSuspended:YES];
}

- (void)resume
{
	[_requestQueue setSuspended:NO];
}

- (void)cancel
{
	[_requestQueue cancelAllOperations];
}
#pragma mark - ASINetworkQueueDelegate
//失败
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"请求失败:%@,%@,",request.responseString,[request.error localizedDescription]);
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    DataRequestType requestType = [[userInformation objectForKey:REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];    
    id  returnObject = [parser objectWithString:responseString];
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [returnObject  objectForKey:@"IsOk"];
        if ([errorString intValue]==0) {
            NSLog(@"数据错误!");
        }
    }
    
    NSDictionary *userInfo = nil;
    NSArray *userArr = nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        userInfo = (NSDictionary*)returnObject;
    }
    else if ([returnObject isKindOfClass:[NSArray class]]) {
        userArr = (NSArray*)returnObject;
    }
    else {
        return;
    }
    
    
    //获取当前区域列表
    if (requestType == AAGetSearchList) {
        NSArray *arr= [userInfo objectForKey:@"results"];
        NSMutableArray  *statuesArr = [[NSMutableArray alloc]initWithCapacity:0];
        
        if ([_delegate respondsToSelector:@selector(didGetSearchList:)]) {
            [_delegate didGetSearchList:statuesArr];
        }
    }
    //
    if (requestType == AAGetRadiusList) {
        NSArray *arr= [userInfo objectForKey:@"results"];
        NSMutableArray  *statuesArr = [[NSMutableArray alloc]initWithCapacity:0];
        
        if ([_delegate respondsToSelector:@selector(didGetRadiusSearchList:)]) {
            [_delegate didGetRadiusSearchList:statuesArr];
        }
    }
    
    //继续添加
    
    
    
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"请求将要跳转");
}

@end

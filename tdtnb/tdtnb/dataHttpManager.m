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
#import "XMLReader.h"


#define TIMEOUT 30

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
    NSString *baseUrl =[NSString  stringWithFormat:@"%@",HTTP_URL];
    NSURL  *url = [self generateURL:baseUrl params:params];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    NSLog(@"url=%@",url);
    [request setTimeOutSeconds:TIMEOUT];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [self setGetUserInfo:request withRequestType:AAGetSearchList];
    [_requestQueue addOperation:request];
}
//
-(void)letDoRadiusSearchWithQuery:(NSString *)query location:(NSString *)location  radius:(int)radius scope:(int)scope pageSize:(int)size pageNum:(int)num{
    NSString *q = [NSString stringWithFormat:@"%d",radius];
    NSString *r = [NSString stringWithFormat:@"%d",scope];
    NSString *s = [NSString stringWithFormat:@"%d",size];
    NSString *n = [NSString stringWithFormat:@"%d",num];
    NSMutableDictionary     *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:  query, @"query",location,  @"location",s,  @"page_size",n,  @"page_num",r,  @"scope",q,  @"radius",@"yMMBb6l8GBeG6GcHjnNuHVMy",  @"ak",@"json", @"output",nil];
    NSString *baseUrl =[NSString  stringWithFormat:@"%@",HTTP_URL];
    NSURL  *url = [self generateURL:baseUrl params:params];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:TIMEOUT];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [self setGetUserInfo:request withRequestType:AAGetRadiusList];
    [_requestQueue addOperation:request];
}
- (void)letDoPostErrorWithMessage:(NSString *)message plottingScale:(NSString *)plottingScale point:(NSString *)point{
    NSString *m = [NSString stringWithFormat:@"%@",message];
    NSString *s = [NSString stringWithFormat:@"%@",plottingScale];
    NSString *p = [NSString stringWithFormat:@"%@",point];
    NSString *baseUrl =[NSString  stringWithFormat:@"%@",HTTP_ERRORURL];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"admin" forKey:@"errorCorrector"];
    [request setPostValue:s forKey:@"plottingScale"];
    [request setPostValue:m forKey:@"errorCorrectInfo"];
    [request setPostValue:@"0" forKey:@"errorcoreectObject"];
    [request setPostValue:@"" forKey:@"telnum"];
    [request setPostValue:p forKey:@"point"];
    [request setPostValue:@"1" forKey:@"region"];
    [request setTimeOutSeconds:TIMEOUT];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [self setPostUserInfo:request withRequestType:AAPostError];
    [request startAsynchronous];
}

//
-(void)letDoLineSearchWithOrig:(NSString *)orig dest:(NSString *)dest style:(NSString *)style{
    NSString *m = [NSString stringWithFormat:@"%@",orig];
    NSString *s = [NSString stringWithFormat:@"%@",dest];
    NSString *p = [NSString stringWithFormat:@"%@",style];
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/route.do",HTTP_SEARCH_URL];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[NSString stringWithFormat:@"{'orig':'%@','dest':'%@','style':'%@'}",m,s,p] forKey:@"routeStr"];
    [request setTimeOutSeconds:TIMEOUT];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request setDelegate:self];
    [self setPostUserInfo:request withRequestType:AAGetLineSearch];
    [request startAsynchronous];

}
//
-(void)letDoBusSearchWithStartposition:(NSString *)startposition endposition:(NSString *)endposition linetype:(NSString *)linetype{
    NSString *m = [NSString stringWithFormat:@"%@",startposition];
    NSString *s = [NSString stringWithFormat:@"%@",endposition];
    NSString *p = [NSString stringWithFormat:@"%@",linetype];
    NSString *baseUrl =[NSString  stringWithFormat:@"%@/BuslineServlet.do?postStr=%@startposition:'%@',endposition:'%@',linetype:'%@'%@",HTTP_SEARCH_URL,@"%7b",m,s,p,@"%7d"];
    NSURL  *url = [NSURL URLWithString:baseUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setTimeOutSeconds:TIMEOUT];
    [request setResponseEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:AAGetBusSearch];
    [_requestQueue addOperation:request];
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
    if ([_delegate respondsToSelector:@selector(didGetFailed)]) {
        [_delegate didGetFailed];
    }
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    DataRequestType requestType = [[userInformation objectForKey:REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];    
    id  returnObject = [parser objectWithString:responseString];
    if(!returnObject && responseString){
        NSError *parseError = nil;
        returnObject= [XMLReader dictionaryForXMLString:responseString error:&parseError];
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
        if ([_delegate respondsToSelector:@selector(didGetFailed)]) {
            [_delegate didGetFailed];
        }
    }
    
    
    //获取当前区域列表
    if (requestType == AAGetSearchList) {
        NSArray *arr= [userInfo objectForKey:@"results"];
        NSMutableArray  *statuesArr = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSDictionary *item in arr){
            NBSearch *result = [NBSearch searchWithJsonDictionary:item];
            [statuesArr addObject:result];
        }
        if ([_delegate respondsToSelector:@selector(didGetSearchList:)]) {
            [_delegate didGetSearchList:statuesArr];
        }
    }
    //
    if (requestType == AAGetRadiusList) {
        NSArray *arr= [userInfo objectForKey:@"results"];
        NSMutableArray  *statuesArr = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSDictionary *item in arr){
            NBSearch *result = [NBSearch searchWithJsonDictionary:item];
            [statuesArr addObject:result];
        }
        if ([_delegate respondsToSelector:@selector(didGetRadiusSearchList:)]) {
            [_delegate didGetRadiusSearchList:statuesArr];
        }
    }
    //
    if(requestType == AAPostError){
        NSString *string= [userInfo objectForKey:@"success"];
        if ([_delegate respondsToSelector:@selector(didPostError:)]) {
            if([string isEqualToString:@"false"]){
                [_delegate didPostError:@"提交纠错信息异常"];
            }else{
                [_delegate didPostError:@"提交纠错信息成功"];
            }
        }
    }
    //
    if(requestType == AAGetLineSearch){
        NSDictionary *arr= [userInfo objectForKey:@"result"];
        NBRoute *route = nil;
        if([arr count] > 0){
            route = [NBRoute routeWithJsonDictionary:arr];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didGetRoute:)] && route) {
            [_delegate didGetRoute:route];
        }
    }
    //
    if(requestType == AAGetBusSearch){
        NSArray *arr= [[[userInfo objectForKey:@"results"] objectAtIndex:0] objectForKey:@"lines"];
        NSMutableArray  *statuesArr = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSDictionary *item in arr){
            NBLine *line = [NBLine lineWithJsonDictionary:item];
            [statuesArr addObject:line];
        }
        if ([_delegate respondsToSelector:@selector(didGetBusLines:)]) {
            [_delegate didGetBusLines:statuesArr];
        }

    }
    
    //继续添加
    
    
    
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"请求将要跳转");
}


@end

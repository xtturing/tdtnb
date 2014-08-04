//
//  dataHttpManager.h
//  房伴
//
//  Created by tao xu on 13-8-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "StringUtil.h"
#import "NSStringAdditions.h"

#define HTTP_URL              @"http://www.szlife360.com/villa"
#define REQUEST_TYPE          @"requestType"

typedef enum {
    AAGetSearchList = 0,           //获取当前区域列表
    AAGetRadiusList,
    //继续添加
    
}DataRequestType;


@class ASINetworkQueue;


//Delegate
@protocol dataHttpDelegate <NSObject>
@optional
//获取到当前区域列表
-(void)didGetSearchList:(NSArray*)searchList;
//
-(void)didGetRadiusSearchList:(NSArray *)radiusList;
//继续添加
@end


@interface dataHttpManager : NSObject

@property (nonatomic,retain) ASINetworkQueue *requestQueue;
@property (nonatomic,assign) id<dataHttpDelegate> delegate;
+(dataHttpManager*)getInstance;
- (id)initWithDelegate;

- (BOOL)isRunning;
- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
//获取当前区域列表
-(void)letDoSearchWithQuery:(NSString *)query region:(NSString *)region searchType:(int)type pageSize:(int)size pageNum:(int)num;

//
-(void)letDoRadiusSearchWithQuery:(NSString *)query location:(NSString *)location  radius:(int)radius scope:(int)scope pageSize:(int)size pageNum:(int)num;

//继续添加
@end

//
//  NBSimpleRoute.m
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSimpleRoute.h"

@implementation NBSimpleRoute


- (NBSimpleRoute *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        _rid=[dic getStringValueForKey:@"id" defaultValue:@""];
        _strguide=[[dic objectForKey:@"strguide"] getStringValueForKey:@"text" defaultValue:@""];
        _streetNames=[[dic objectForKey:@"streetNames"] getStringValueForKey:@"text" defaultValue:@""];
        _lastStreetName=[[dic objectForKey:@"lastStreetName"] getStringValueForKey:@"text" defaultValue:@""];
        _linkStreetName=[[dic objectForKey:@"linkStreetName"] getStringValueForKey:@"text" defaultValue:@""];
        _turnlatlon=[[dic objectForKey:@"turnlatlon"] getStringValueForKey:@"text" defaultValue:@""];
        _streetLatLon=[[dic objectForKey:@"streetLatLon"] getStringValueForKey:@"text" defaultValue:@""];
        _streetDistance=[[dic objectForKey:@"streetDistance"] getStringValueForKey:@"text" defaultValue:@""];
        _segmentNumber=[[dic objectForKey:@"segmentNumber"] getStringValueForKey:@"text" defaultValue:@""];
    }
	return self;
}

+ (NBSimpleRoute *)simpleRouteWithJsonDictionary:(NSDictionary*)dic{
    
    return [[NBSimpleRoute alloc] initWithJsonDictionary:dic];
}

@end

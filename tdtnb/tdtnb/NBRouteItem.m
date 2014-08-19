//
//  NBRouteItem.m
//  tdtnb
//
//  Created by xtturing on 14-8-19.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBRouteItem.h"

@implementation NBRouteItem
- (NBRouteItem *)initWithJsonDictionary:(NSDictionary*)dic{
    if (self = [super init]) {
        _rid=[dic getStringValueForKey:@"id" defaultValue:@""];
        _strguide=[[dic objectForKey:@"strguide"] getStringValueForKey:@"text" defaultValue:@""];
        _streetName=[[dic objectForKey:@"streetName"] getStringValueForKey:@"text" defaultValue:@""];
        _nextStreetName=[[dic objectForKey:@"nextStreetName"] getStringValueForKey:@"text" defaultValue:@""];
        _turnlatlon=[[dic objectForKey:@"turnlatlon"] getStringValueForKey:@"text" defaultValue:@""];
    }
	return self;
}

+ (NBRouteItem *)routeItemWithJsonDictionary:(NSDictionary*)dic{
    return [[NBRouteItem alloc] initWithJsonDictionary:dic];
}

@end

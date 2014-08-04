//
//  NBSearch.m
//  tdtnb
//
//  Created by xtturing on 14-8-4.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import "NBSearch.h"

@implementation NBSearch

- (NBSearch *)initWithJsonDictionary:(NSDictionary*)dic {
	if (self = [super init]) {
        _name=[dic getStringValueForKey:@"name" defaultValue:@""];
        _location=[dic getStringValueForKey:@"location" defaultValue:@""];
        _address=[dic getStringValueForKey:@"address" defaultValue:@""];
        _street_id=[dic getStringValueForKey:@"street_id" defaultValue:@""];
        _telephone=[dic getStringValueForKey:@"telephone" defaultValue:@""];
        _uid=[dic getStringValueForKey:@"uid" defaultValue:@""];
    }
	return self;
}

+ (NBSearch *)searchWithJsonDictionary:(NSDictionary*)dic
{
	return [[NBSearch alloc] initWithJsonDictionary:dic];
}

@end

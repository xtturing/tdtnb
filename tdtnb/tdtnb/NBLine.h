//
//  NBLine.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBSegment.h"

@interface NBLine : NSObject

@property (nonatomic, strong) NSString *lineName;
@property (nonatomic, strong) NSArray *segments;

@end

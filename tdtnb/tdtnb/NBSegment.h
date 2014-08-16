//
//  NBSegment.h
//  tdtnb
//
//  Created by xtturing on 14-8-17.
//  Copyright (c) 2014年 xtturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBStationStart.h"
#import "NBStationEnd.h"
#import "NBSegmentLine.h"

@interface NBSegment : NSObject

@property (nonatomic, strong) NSString *segmentType;
@property (nonatomic, strong) NBStationStart *stationStart;
@property (nonatomic, strong) NBStationEnd *stationEnd;
@property (nonatomic, strong) NSArray *segmentLines;

@end

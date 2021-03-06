//
//  JSAConstants.h
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

extern NSString * const kJSAParseAppID;
extern NSString * const kJSAParseClientKey;

#define MAX_DISTANCE_MI 100
#define YARDS_IN_MILE 1760
#define MILE_IN_YARDS 0.000568182


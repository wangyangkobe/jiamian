//
//  UtilityLib.m
//  JiaMian
//
//  Created by wanyang on 14-8-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "UtilityLib.h"

@implementation UtilityLib
+ (instancetype)instance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
@end

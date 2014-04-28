//
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
   if ([propertyName isEqualToString: @"background_no"]) return YES;
  	return NO;
}

@end
//
// Area.h
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface AreaModel : JSONModel

@property(nonatomic, assign) int       area_id;
@property(nonatomic, strong) NSString* area_name;
@property(nonatomic, assign) int       type;
@property(nonatomic, strong) NSString* type_name;
@property(nonatomic, strong) NSString* city;

@end
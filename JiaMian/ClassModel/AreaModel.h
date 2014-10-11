//
// Area.h
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol AreaModel
@end

@interface AreaModel : JSONModel <NSCopying, NSCoding>

@property(nonatomic, assign) int       area_id;
@property(nonatomic, strong) NSString* area_name;
@property(nonatomic, assign) int       hots;
@property(nonatomic, assign) int       type;
@property(nonatomic, assign) int       sequence;
@property(nonatomic, strong) NSString* type_name;
@property(nonatomic, strong) NSString* city;

@end

@interface Areas : JSONModel
@property(strong, nonatomic) NSArray<AreaModel>* areas;
@end
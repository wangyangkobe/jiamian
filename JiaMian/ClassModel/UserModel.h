//
// User.h
// JSON
//
// Created by wy on 13-11-12.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AreaModel.h"
@interface UserModel : JSONModel <NSCopying, NSCoding>

@property(nonatomic, assign) long                 user_id;
@property(nonatomic, strong) NSString*            user_name;
@property(nonatomic, assign) int                  gender;         // 0-未知，1-男，2-女
@property(nonatomic, strong) NSString<Optional>*  head_image;
@property(nonatomic, assign) int                  user_type;      // 1-QQ，2-Weibo
@property(nonatomic, strong) NSString<Optional>*  description;
@property(nonatomic, strong) AreaModel<Optional>* area;
@property(nonatomic, strong) NSArray<AreaModel, Optional>* areas;

+ (void)saveUserModelObject:(UserModel*) object key:(NSString*)key;
+ (UserModel*)loadUserModelObjectWithKey:(NSString*)key;
@end


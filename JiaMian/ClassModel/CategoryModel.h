//
//  CategoryModel.h
//  JiaMian
//
//  Created by wanyang on 14-8-24.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CategoryModel
@end

@interface CategoryModel : JSONModel

@property (nonatomic, copy) NSString* description;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* background_url;
@property (nonatomic, assign) NSInteger category_id;
@property (nonatomic, assign) NSInteger category_type;

@end

@interface Categories : JSONModel

@property(strong, nonatomic) NSArray<CategoryModel>* categories;

@end
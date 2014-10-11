//
//  BannerModel.h
//  JiaMian
//
//  Created by wanyang on 14-8-24.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BannerModel
@end

@interface BannerModel : JSONModel
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString<Optional>* description;
@property (nonatomic, assign) NSInteger banner_id;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* background_url;
@property (nonatomic, assign) NSInteger banner_type;
@property (nonatomic, assign) NSInteger category_type;
@end


@interface Banners : JSONModel

@property(strong, nonatomic) NSArray<BannerModel>* banners;

@end
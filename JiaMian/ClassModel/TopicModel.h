//
//  TopicModel.h
//  JiaMian
//
//  Created by wy on 14-7-6.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol TopicModel
@end


@interface TopicModel : JSONModel <NSCopying, NSCoding>

@property (nonatomic, assign) long topic_id;
@property (nonatomic, strong) NSString* topic_title;
@property (nonatomic, assign) int message_count;
@property (nonatomic, strong) NSString* background_color;
@property (nonatomic, strong) NSString<Optional>* img_url;
@property (nonatomic, copy) MessageModel<Optional>* latest_message;

@end


@interface Topics : JSONModel

@property(strong, nonatomic) NSArray<TopicModel>* topics;

@end
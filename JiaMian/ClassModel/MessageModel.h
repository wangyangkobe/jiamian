// MessageModel.h
//
// Created by wy on 13-11-16.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AreaModel.h"
#import "UserModel.h"

@protocol MessageModel
@end

@interface MessageModel : JSONModel

@property(nonatomic, strong) NSString*           create_at;
@property(nonatomic, assign) long                message_id;
@property(nonatomic, assign) int                 message_type;    // 1-文本消息(默认)，2-（语音...）
@property(nonatomic, strong) NSString<Optional>* text;
@property(nonatomic, assign) int                 comments_count;  //评论数目
@property(nonatomic, assign) int                 likes_count;     //点赞数目
@property(nonatomic, assign) int                 background_type; //背景图片类型，1-序号，2-图片URL
@property(nonatomic, assign) int                 background_no;   //背景图片序号（仅当type为1有效，否则null）
@property(nonatomic, strong) NSString<Optional>* background_url;  //背景图片序号（仅当type为2有效，否则null）
@property(nonatomic, strong) AreaModel*          area;
@property(nonatomic, strong) UserModel<Optional>* user;
@property(nonatomic, assign) BOOL                is_official;

@end

@interface Messages : JSONModel

@property(strong, nonatomic) NSArray<MessageModel>* messages;

@end
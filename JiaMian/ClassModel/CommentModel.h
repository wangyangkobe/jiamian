//
// CommentModel.h
//
// Created by wy on 13-12-6.
// Copyright (c) 2013年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "JSONModel.h"

@interface CommentModel : JSONModel

@property(nonatomic, copy) NSString*      create_at;
@property(nonatomic, assign) long         comment_id;
@property(nonatomic, assign) long         message_id;
@property(nonatomic, copy) NSString*      user_head;
@property(nonatomic, copy) NSString*      text;
@property (assign, nonatomic) BOOL        is_starter;
@property(nonatomic, strong) UserModel*   user;

@end
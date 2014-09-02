//
//  VoteModel.h
//  JiaMian
//
//  Created by wanyang on 14-9-1.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VoteModel
@end

@interface VoteModel : NSObject

@property (nonatomic, assign) NSInteger voteId;
@property (nonatomic, copy)   NSString* content;
@property (nonatomic, assign) NSInteger pecentage;

@end

@interface Votes : JSONModel

@property(strong, nonatomic) NSArray<VoteModel>* votes;

@end
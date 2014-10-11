//
//  MsgTableViewCell.h
//  JiaMian
//
//  Created by wanyang on 14-8-28.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MsgTableViewCellDelegate <NSObject>
@optional
- (void)removeMoreBtnViewFromCell;
@end

@interface MsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blackImageView;
@property (weak, nonatomic) IBOutlet UILabel *msgTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moreImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteImageView;

@property (weak, nonatomic) id<MsgTableViewCellDelegate> delegate;
@end

//
//  MsgTableViewCell.m
//  JiaMian
//
//  Created by wanyang on 14-8-28.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "MsgTableViewCell.h"

@implementation MsgTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse
{
    [super prepareForReuse];    
    self.selectionStyle = UITableViewCellAccessoryNone;
    [self.areaLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.msgTextLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.likeNumLabel setTextColor:UIColorFromRGB(0xffffff)];
    
    [self.likeImageView setUserInteractionEnabled:YES];
}
@end

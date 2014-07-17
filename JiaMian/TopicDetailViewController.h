//
//  TopicDetailViewController.h
//  JiaMian
//
//  Created by wy on 14-7-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet PullTableView *pullTableView;

@property (nonatomic, copy) TopicModel* topic;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

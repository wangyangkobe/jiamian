//
//  PublishMsgViewController.h
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiniuSimpleUploader.h"
#import "QiniuPutPolicy.h"
#import "QiniuConfig.h"
#import "SAMTextView.h"

@interface PublishMsgViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (assign, nonatomic) BOOL isTouPiao;
@property (assign, nonatomic) int categoryId;
@property(weak,nonatomic)id delegate;
@end

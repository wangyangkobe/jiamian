//
//  HomePageViewController.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDetailViewController.h"

@interface MessageListViewController : UIViewController<refreshTableViewCell>

@property (weak, nonatomic) IBOutlet PullTableView *pullTableView;
- (IBAction)publishMessage:(id)sender;
@property (nonatomic, assign) NSInteger categoryId;

@end

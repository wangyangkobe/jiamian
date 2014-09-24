//
//  HomePageViewController.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol passBackTheStr <NSObject>



@end
@interface MessageListViewController : UIViewController

@property (weak, nonatomic) IBOutlet PullTableView *pullTableView;
- (IBAction)publishMessage:(id)sender;
@property (nonatomic, assign) NSInteger categoryId;

@end

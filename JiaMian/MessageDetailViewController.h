//
//  MessageDetailViewController.h
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

//@property (copy, nonatomic) NSString* msgText;
@property (strong, nonatomic) MessageModel* selectedMsg;
@end

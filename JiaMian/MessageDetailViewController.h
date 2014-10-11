//
//  MessageDetailViewController.h
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol refreshTableViewCell <NSObject>
-(void)refreshTableViewCell:(NSIndexPath*)indexPath withArray:(NSArray*)arr withOther:(MessageModel*)othArr;
@end

@interface MessageDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic,strong) NSIndexPath*selectedPath;
@property(nonatomic,weak) id<refreshTableViewCell> delegate;
@property (strong, nonatomic) MessageModel* selectedMsg;
@end

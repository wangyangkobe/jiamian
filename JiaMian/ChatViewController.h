//
//  PublishSiXinViewController.h
//  JiaMian
//
//  Created by wanyang on 14-8-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@interface ChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
//@property (copy, nonatomic) HxUserModel* hxUserInfo;
@property (assign, nonatomic) NSInteger customFlag;
@property (copy, nonatomic) NSString* chatter;
@property (copy, nonatomic) NSString* myHeadImage;
@property (copy, nonatomic) NSString* chatterHeadImage;
@property (copy, nonatomic) MessageModel* message;
@end

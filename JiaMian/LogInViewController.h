//
//  LogInViewController.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController

- (IBAction)sinaWBLogIn:(id)sender;
- (IBAction)tencentQQLogIn:(id)sender;
- (IBAction)logInWithForOldUser:(id)sender;  //老用户登录
- (IBAction)jonInNowPressed:(id)sender;      //立即加入
- (IBAction)enterBtnPress:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *sinaBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *joinIn;


@end

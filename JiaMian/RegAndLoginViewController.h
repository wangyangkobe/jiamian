//
//  RegAndLoginViewController.h
//  JiaMian
//
//  Created by wanyang on 14-8-30.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegAndLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passWordTF;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (assign, nonatomic) BOOL  isRegister; //区分登陆和注册

@property (weak, nonatomic) IBOutlet UILabel *userNameHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *passWordHintLabel;


- (IBAction)handleBtnPressed:(id)sender;
@end

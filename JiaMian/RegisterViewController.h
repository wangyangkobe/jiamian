//
//  RegisterViewController.h
//  JiaMian
//
//  Created by wy on 14-6-4.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UITextField *userName;
- (IBAction)returnBtnPress:(id)sender;
- (IBAction)forgetPassWord:(id)sender;
- (IBAction)registerBtnPress:(id)sender;
- (IBAction)logInBtnPress:(id)sender;

@end

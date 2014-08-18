//
//  PublishSiXinViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "PublishSiXinViewController.h"

@interface PublishSiXinViewController () <UITextFieldDelegate, IChatManagerDelegate>
{
    UIButton* sendButton; //发送按钮
    UITextField* textField;
}
@end

@implementation PublishSiXinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureToolBar];
    // 注册一个delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleBackGroundTapped)];
    oneTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneTap]; //通过鼠标手势来实现键盘的隐藏
}
- (void)handleBackGroundTapped {
    [textField resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
// 实现接收消息的委托
#pragma mark - IChatManagerDelegate
- (void)didReceiveMessage:(EMMessage *)message {
	
}
- (void)sendPrivateMessage {
    EMChatText *text = [[EMChatText alloc] initWithText:textField.text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    EMMessage *msg = [[EMMessage alloc] initWithReceiver:_hxUserInfo.user.easemob_name bodies:@[body]];
    [[EaseMob sharedInstance].chatManager sendMessage:msg progress:nil error:nil];
}
#pragma mark 监听键盘的显示与隐藏
- (void)inputKeyboardWillShow:(NSNotification *)notification {
    CGRect keyboardEndRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // Convert the frame from window's coordinate system to our view's coordinate system.
    keyboardEndRect = [self.view convertRect:keyboardEndRect fromView:window];
    
    /* Find out how much of our view is being covered by the keyboard */
    //CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(self.view.frame, keyboardEndRect);
    
    /* Scroll the scroll view up to show the full contents of our view */
    [UIView animateWithDuration:animationTime animations:^{
        [self.toolBar setFrame:CGRectMake(0, keyboardEndRect.origin.y  - 44, SCREEN_WIDTH, TOOLBAR_HEIGHT)];
    }];
}
- (void)inputKeyboardWillHide:(NSNotification *)notification {
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationTime animations:^{
        [self.toolBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 44*2 - 20, SCREEN_WIDTH, TOOLBAR_HEIGHT)];
    }];
}
- (void)configureToolBar
{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 7, 250, 30)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:13.0f];
    textField.backgroundColor = [UIColor whiteColor];
    textField.returnKeyType = UIReturnKeySend;
    [self.toolBar addSubview:textField];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(280, 7, 40, 30)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendPrivateMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:sendButton];
}
@end

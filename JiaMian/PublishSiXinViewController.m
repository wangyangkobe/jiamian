//
//  PublishSiXinViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "PublishSiXinViewController.h"

@interface PublishSiXinViewController () <UITextFieldDelegate, IChatManagerDelegate, IDeviceManagerDelegate, HPGrowingTextViewDelegate>
{
    HPGrowingTextView *textView;
    UIButton* sendButton;  //发送按钮
    
    dispatch_queue_t _messageQueue;
}
@property (strong, nonatomic) NSMutableArray* dataSource;   //tableView数据源
@property (strong, nonatomic) EMConversation* conversation; //会话管理者
@end

#define KPageCount 20

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
    NSLog(@"easemob_name = %@", _hxUserInfo.user.easemob_name);
    //根据接收者的username获取当前会话的管理者
    _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_hxUserInfo.user.easemob_name isGroup:NO];
    
    // 以下三行代码必须写，注册为SDK的ChatManager的delegate
    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    // 注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [self configureToolBar];
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleBackGroundTapped)];
    oneTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneTap]; //通过鼠标手势来实现键盘的隐藏
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    //通过会话管理者获取已收发消息
    [self loadMoreMessages];
}
- (void)loadMoreMessages {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSInteger currentCount = [weakSelf.dataSource count];
        EMMessage *latestMessage = [weakSelf.conversation latestMessage];
        NSTimeInterval beforeTime = 0;
        if (latestMessage) {
            beforeTime = latestMessage.timestamp + 1;
        }else{
            beforeTime = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        }
        
        NSArray *chats = [weakSelf.conversation loadNumbersOfMessages:(currentCount + KPageCount) before:beforeTime];
        NSLog(@"%s %@", __FUNCTION__, chats);
        if ([chats count] > currentCount) {
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:chats];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.bubbleTable reloadData];
                [weakSelf.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
    });
}
- (void)handleBackGroundTapped {
    [textView resignFirstResponder];
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
    // 设置当前conversation的所有message为已读
    [_conversation markMessagesAsRead:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[[EaseMob sharedInstance] deviceManager] removeDelegate:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - IChatManagerDelegate
- (void)didReceiveMessage:(EMMessage *)message {
    NSLog(@"%s", __FUNCTION__);
    if ([_conversation.chatter isEqualToString:message.conversation.chatter]) {
        [self addChatDataToMessage:message];
    }
}
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error {
    NSLog(@"%s", __FUNCTION__);
    // [self reloadTableViewDataWithMessage:message];
}

-(void)addChatDataToMessage:(EMMessage *)message {
}

- (void)sendPrivateMessage {
    EMChatText *text = [[EMChatText alloc] initWithText:textView.text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    EMMessage* msg = [[EMMessage alloc] initWithReceiver:_hxUserInfo.user.easemob_name bodies:@[body]];
    EMMessage* message = [[EaseMob sharedInstance].chatManager sendMessage:msg progress:nil error:nil];
    NSLog(@"%s, %@", __FUNCTION__, message);
    [textView setText:@""];
    [textView resignFirstResponder];
}


#pragma mark - UIKeyboardWillShowNotification
- (void)inputKeyboardWillShow:(NSNotification *)notification {
    CGRect keyboardEndRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationTime  = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // Convert the frame from window's coordinate system to our view's coordinate system.
    keyboardEndRect = [self.view convertRect:keyboardEndRect fromView:window];
    // get a rect for the textView frame
	CGRect toolBarFrame = self.toolBar.frame;
    toolBarFrame.origin.y = self.view.bounds.size.height - (keyboardEndRect.size.height + toolBarFrame.size.height);
    
    [UIView animateWithDuration:animationTime animations:^{
        self.toolBar.frame = toolBarFrame;
    }];
}
- (void)inputKeyboardWillHide:(NSNotification *)notification {
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // get a rect for the textView frame
	CGRect toolBarFrame = self.toolBar.frame;
    toolBarFrame.origin.y = self.view.bounds.size.height - toolBarFrame.size.height;

    [UIView animateWithDuration:animationTime animations:^{
        self.toolBar.frame = toolBarFrame;
    }];
}


#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = self.toolBar.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.toolBar.frame = r;
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] )  //控制输入文本的长度
        return NO;
    else
        return YES;
}
- (void)configureToolBar {
    CGRect frame = CGRectMake(0, 0, 255, 44);
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectInset(frame, 8, 5)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeySend; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = textView.frame;
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius = 5.0;
    
    [self.toolBar addSubview:textView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(self.toolBar.frame.size.width - 69, 8, 63, 27);
    sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendBtn setTitle:@"评论" forState:UIControlStateNormal];
    
    [sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendBtn addTarget:self action:@selector(sendPrivateMessage) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.toolBar addSubview:sendBtn];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}
@end

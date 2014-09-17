//
//  PublishSiXinViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITextFieldDelegate, IChatManagerDelegate, IDeviceManagerDelegate, HPGrowingTextViewDelegate, UIBubbleTableViewDataSource>
{
    HPGrowingTextView *textView;
    UIButton* sendButton;  //发送按钮
    UIRefreshControl* refreshControl;
}
@property (strong, nonatomic) NSMutableArray* dataSource;   //tableView数据源
@property (strong, nonatomic) EMConversation* conversation; //会话管理者
@end

#define KPageCount 10

@implementation ChatViewController

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
    self.title = @"私信";
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [self.bubbleTable addSubview:refreshControl];
    
    NSLog(@"easemob_name = %@, myHeadImage = %@, other = %@", _chatter, _myHeadImage, _chatterHeadImage);
    //根据接收者的username获取当前会话的管理者
    _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_chatter isGroup:NO];
    
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
    
    self.bubbleTable.bubbleDataSource = self;
    self.bubbleTable.snapInterval = 120;
    self.bubbleTable.showAvatars = YES;
    //通过会话管理者获取已收发消息
    NSArray *chats = [_conversation loadNumbersOfMessages:KPageCount before:[_conversation latestMessage].timestamp + 1];
    for (EMMessage* element in chats) {
        NSBubbleData* bubbleData = [self convert2BubbleData:element];
        if (bubbleData) {
            [self.dataSource addObject:bubbleData];
        }
    }
    [self.bubbleTable reloadData];
}

-(NSBubbleData*)convert2BubbleData:(EMMessage *)message {
    EMTextMessageBody* msgBody = (EMTextMessageBody*)[message.messageBodies lastObject];
    NSDictionary *attribute = [message.ext objectForKey:@"attribute"];
    NSString* customFlag = [attribute objectForKey:@"customFlag"];
    if (customFlag.integerValue != _customFlag) {
        return nil;
    }
    
    NSString* selfHuanXinId = [[NSUserDefaults standardUserDefaults] objectForKey:kSelfHuanXinId];
    NSBubbleData* bubbleData;
    NSDate* msgDate = [NSDate dateWithTimeIntervalSince1970:message.timestamp/1000];
    if ([message.to isEqualToString:selfHuanXinId]) { //收到
        bubbleData = [[NSBubbleData alloc] initWithText:msgBody.text date:msgDate type:BubbleTypeSomeoneElse];
        bubbleData.avatarUrl = [attribute objectForKey:@"myHeaderUrl"];
    } else {
        bubbleData = [[NSBubbleData alloc] initWithText:msgBody.text date:msgDate type:BubbleTypeMine];
        bubbleData.avatarUrl = [attribute objectForKey:@"myHeaderUrl"];
    }
    return bubbleData;
}

- (void)sendPrivateMessage {
    if (0 == [textView.text length])
        return;
    
    EMChatText *text = [[EMChatText alloc] initWithText:textView.text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    EMMessage* sendMsg = [[EMMessage alloc] initWithReceiver:_chatter bodies:@[body]];
    
    NSMutableDictionary* attribute = [NSMutableDictionary dictionary];
    [attribute setObject:[NSString stringWithFormat:@"%ld", (long)_customFlag] forKey:@"customFlag"];
    [attribute setObject:_myHeadImage forKey:@"myHeaderUrl"];
    [attribute setObject:_chatterHeadImage forKey:@"headerUrl"];
    [attribute setObject:[NSNumber numberWithInt:_message.background_no2] forKey:@"msgBackgroundNoNew"];
    [attribute setObject:_message.background_url forKey:@"msgBackgroundUrl"];
    [attribute setObject:[NSNumber numberWithInt:_message.background_type] forKey:@"msgBackgroundType"];
    [attribute setObject:_message.text forKey:@"msgText"];
    [attribute setObject:[NSNumber numberWithLong:_message.message_id] forKey:@"msgId"];
    
    sendMsg.ext = @{@"attribute": attribute};
    
    EMMessage* returnMsg = [[EaseMob sharedInstance].chatManager sendMessage:sendMsg progress:nil error:nil];
    NSLog(@"%@", returnMsg);
    [textView setText:@""];
    [_dataSource addObject:[self convert2BubbleData:returnMsg]];
    [self.bubbleTable reloadData];
    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    [textView resignFirstResponder];
}
- (void)handleRefreshAction:(UIRefreshControl*)sender {
    if (sender.refreshing) {
        [self performSelector:@selector(handleLoadData) withObject:nil afterDelay:2.0f];
    }
}
- (void)handleLoadData {
    NSInteger currentCount = [_dataSource count];
    EMMessage *latestMessage = [_conversation latestMessage];
    NSArray* chats = [_conversation loadNumbersOfMessages:KPageCount + currentCount before:latestMessage.timestamp + 1];
    if (chats.count >= currentCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_dataSource removeAllObjects];
            for (EMMessage* element in chats) {
                NSBubbleData* bubbleData = [self convert2BubbleData:element];
                if (bubbleData) {
                    [self.dataSource addObject:bubbleData];
                }
            }
            [refreshControl endRefreshing];
            [_bubbleTable reloadData];
        });
    }
}

- (void)handleBackGroundTapped {
    [textView resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_dataSource count] > 4)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 44, 0.0);
        self.bubbleTable.contentInset = contentInsets;
        self.bubbleTable.scrollIndicatorInsets = contentInsets;
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
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
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //以下第一行代码必须写，将self从ChatManager的代理中移除
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

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendPrivateMessage];
    return YES;
}
#pragma mark - UIBubbleTableViewDataSource implementation
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [self.dataSource count];
}
- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    return [self.dataSource objectAtIndex:row];
}

#pragma mark - IChatManagerDelegate
- (void)didReceiveMessage:(EMMessage *)message {
    NSLog(@"%s %@", __FUNCTION__, message);
    if ([_conversation.chatter isEqualToString:message.conversation.chatter]) {
        NSBubbleData* bubbleData = [self convert2BubbleData:message];
        if (bubbleData) {
            [_dataSource addObject:bubbleData];
            [_bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        }
    }
}
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error {
    NSLog(@"%s", __FUNCTION__);
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
        // set the content insets
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndRect.size.height + 30, 0.0);
        self.bubbleTable.contentInset = contentInsets;
        self.bubbleTable.scrollIndicatorInsets = contentInsets;
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        self.toolBar.frame = toolBarFrame;
    }];
}
- (void)inputKeyboardWillHide:(NSNotification *)notification {
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // get a rect for the textView frame
	CGRect toolBarFrame = self.toolBar.frame;
    toolBarFrame.origin.y = self.view.bounds.size.height - toolBarFrame.size.height;
    
    [UIView animateWithDuration:animationTime animations:^{
        // set the content insets
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 30, 0.0);
        self.bubbleTable.contentInset = contentInsets;
        self.bubbleTable.scrollIndicatorInsets = contentInsets;
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
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
	sendBtn.frame = CGRectMake(self.toolBar.frame.size.width - 69, 10, 63, 27);
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

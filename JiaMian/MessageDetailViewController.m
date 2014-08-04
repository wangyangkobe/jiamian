//
//  MessageDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "TableHeaderView.h"
#import "SVProgressHUD.h"

#define kCommentCellHeadImage  6000
#define kCommentCellTextLabel  6001
#define kCommentCellTimeLabel  6002

@interface MessageDetailViewController () <UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>
{
    CGFloat headerViewHeight;
    NSMutableArray* commentArr;
    
    HPGrowingTextView *textView;
    UIButton* sendButton;  //发送按钮
}
@end

@implementation MessageDetailViewController

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
    
    UIBarButtonItem* shareMessageBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"分享"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(shareMsgBtnPressed:)];
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        [shareMessageBarBtn setTintColor:[UIColor whiteColor]];
    }
    self.navigationItem.rightBarButtonItem = shareMessageBarBtn;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.tableHeaderView = [self configureTableHeaderView];
    [self configureToolBar];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    commentArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        long msgId = self.selectedMsg.message_id;
        NSArray* requestRes = [[NetWorkConnect sharedInstance] commentShowByMsgId:msgId sinceId:0 maxId:INT_MAX count:INT_MAX];
        [commentArr addObjectsFromArray:requestRes];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
- (void)shareMsgBtnPressed:(id)sender
{
    NSLog(@"%s, %@", __FUNCTION__, sender);
    
    //[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, nil]
    NSString* shareText = [NSString stringWithFormat:@"\"%@\", 分享自%@, @假面App http://t.cn/8sk83lK", self.selectedMsg.text, self.selectedMsg.area.area_name];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMengAppKey
                                      shareText:shareText
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, nil]
                                       delegate:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (UIView*)configureTableHeaderView
{
    TableHeaderView*  myHeader = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView"
                                                                owner:self
                                                              options:nil] objectAtIndex:0];
    CGRect headerFrame = myHeader.frame;
    headerFrame.size.height = SCREEN_WIDTH;
    myHeader.frame = headerFrame;
    myHeader.textLabel.text = self.selectedMsg.text;
    myHeader.areaLabel.text = self.selectedMsg.area.area_name;
    myHeader.commentNumLabel.text = [NSString stringWithFormat:@"%d", self.selectedMsg.comments_count];
    myHeader.likeNumberLabel.text = [NSString stringWithFormat:@"%d", self.selectedMsg.likes_count];
    myHeader.visibleNumberLabel.text = [NSString stringWithFormat:@"%d", self.selectedMsg.visible_count];
    if (_selectedMsg.is_official)
    {
        myHeader.visibleNumberLabel.text = @"all";
        myHeader.areaLabel.text = @"假面官方团队";
    }
    
    if (_selectedMsg.background_url && _selectedMsg.background_url.length > 0)
    {
        [myHeader.bgImageView setImageWithURL:[NSURL URLWithString:_selectedMsg.background_url] placeholderImage:nil];
        UIImage* maskImage = [UIImage imageNamed:@"blackalpha.png"];
        [myHeader.maskImageView setBackgroundColor:[UIColor colorWithPatternImage:maskImage]];
    }
    else
    {
        [myHeader.maskImageView setBackgroundColor:[UIColor clearColor]];
        [myHeader.bgImageView setImage:nil];
        
        int bgImageNo = self.selectedMsg.background_no2;
        if (bgImageNo >=1 && bgImageNo <= 10)
        {
            [myHeader setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
        }
        else
        {
            NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d.png", bgImageNo];
            UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
            [myHeader setBackgroundColor:picColor];
        }
        [myHeader.commentImageView setImage:[UIImage imageNamed:@"comment_white"]];
        [myHeader.areaLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.likeNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.visibleNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.textLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.likeImageView setImage:[UIImage imageNamed:@"ic_like"]];
        [myHeader.visibleImageView setImage:[UIImage imageNamed:@"ic_eyes"]];
    }
    if (self.selectedMsg.has_like)
    {
        [myHeader.likeImageView  setImage:[UIImage imageNamed:@"ic_liked"]];
    }
    
    [myHeader.likeImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageTap:)];
    [likeImageTap setNumberOfTapsRequired:1];
    [myHeader.likeImageView addGestureRecognizer:likeImageTap];
    [myHeader.juBaoButton addTarget:self action:@selector(handleJuBaoBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer* hiddenKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
    [hiddenKeyBoard setNumberOfTapsRequired:1];
    [myHeader addGestureRecognizer:hiddenKeyBoard];
    [_tableView addGestureRecognizer:hiddenKeyBoard];
    return myHeader;
}
- (void)hiddenKeyBoard:(UITapGestureRecognizer*)gestureRecognizer
{
    [textView resignFirstResponder];
}
- (void)likeImageTap:(UITapGestureRecognizer*)gestureRecognizer
{
    if (self.selectedMsg.has_like)
        return;
    TableHeaderView* headerView = (TableHeaderView*)[gestureRecognizer.view superview];
    [headerView.likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    [headerView.likeNumberLabel setText:[NSString stringWithFormat:@"%d", self.selectedMsg.likes_count + 1]];
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:self.selectedMsg.message_id];
    if (message)
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:message forKey:@"changedMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"msgChangedNoti" object:self userInfo:userInfo];
        self.selectedMsg = message;
        if (message.is_official == NO)
        {
            [UIView animateForVisibleNumberInView:headerView];
            headerView.visibleNumberLabel.text = [NSString stringWithFormat:@"%d", message.visible_count];
        }
    }
}
- (void)handleJuBaoBtnPress:(UIButton*)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请输入举报理由:"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            AlertContent(@"您的举报请求我们已收到，我们会在24小时内对这条消息进行审核，如果您的举报属实，这条消息将会被删除.");
        }
        else if (buttonIndex == alertView.cancelButtonIndex)
        {
            NSLog(@"Cancelled.");
        }
    };
    av.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView) {
        return ([[[alertView textFieldAtIndex:0] text] length] > 0);
    };
    [av show];
}
#pragma mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentArr count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel* currentComment = (CommentModel*)[commentArr objectAtIndex:indexPath.row];
    static NSString* CellIdentifier = @"CommentCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    UIImageView* headImageView = (UIImageView*)[cell.contentView viewWithTag:kCommentCellHeadImage];
    UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:kCommentCellTextLabel];
    UILabel* timeLabel = (UILabel*)[cell.contentView viewWithTag:kCommentCellTimeLabel];
    textLabel.text = currentComment.text;
    [textLabel setTextColor:UIColorFromRGB(0x787B7E)];
    
    if(currentComment.is_starter) //楼主
    {
        timeLabel.text = [NSString stringWithFormat:@"楼主  %@", [NSString convertTimeFormat:currentComment.create_at]];
        [textLabel setTextColor:UIColorFromRGB(0xff9000)];
    }
    else
        timeLabel.text = [NSString stringWithFormat:@"%d楼  %@", (int)indexPath.row + 1,
                          [NSString convertTimeFormat:currentComment.create_at]];
    
    [timeLabel setTextColor:UIColorFromRGB(0xAFB3B6)];
    [headImageView setImageWithURL:[NSURL URLWithString:currentComment.user_head] placeholderImage:nil];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel* currentComment = [commentArr objectAtIndex:indexPath.row];
    float textHight = [NSString textHeight:currentComment.text
                              sizeWithFont:[UIFont systemFontOfSize:17]
                         constrainedToSize:CGSizeMake(260, 9999)];
    
    if (IOS_NEWER_OR_EQUAL_TO_7)
        return textHight + 23 + 7;
    else
        return textHight + 23;
}
- (void)configureToolBar
{
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"匿名发表评论";
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius =5.0;
    
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
	[sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.toolBar addSubview:sendBtn];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark 监听键盘的显示与隐藏
- (void)keyboardWillShow:(NSNotification*)note
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.toolBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.toolBar.frame = containerFrame;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardBounds.size.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    if (commentArr.count >=1)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:commentArr.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
	// commit animations
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.toolBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.toolBar.frame = containerFrame;
	
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.toolBar.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.toolBar.frame = r;
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )  //控制输入文本的长度
        return NO;
    else
        return YES;
    
}
- (void)sendBtnPressed:(id)sender
{
    NSLog(@"call: %s", __FUNCTION__);
	[textView resignFirstResponder];
    
    if ([textView.text length] > 0)
    {
        if (IOS_NEWER_OR_EQUAL_TO_7) {
            [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 120)];
        } else {
            [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
        }
        
        [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
        [SVProgressHUD showWithStatus:@"发送中..."];
        
        [self performSelector:@selector(sendComment:) withObject:textView.text afterDelay:0.3];
    }
}
- (void)sendComment:(NSString*)commentStr
{
    CommentModel* comment = [[NetWorkConnect sharedInstance] commentCreate:self.selectedMsg.message_id text:textView.text];
    [SVProgressHUD dismiss];
    if (comment)
    {
        MessageModel* msg = [[NetWorkConnect sharedInstance] messageShowByMsgId:comment.message_id];
        self.selectedMsg = msg;
        TableHeaderView* headerView = (TableHeaderView*)self.tableView.tableHeaderView;
        headerView.commentNumLabel.text = [NSString stringWithFormat:@"%d", self.selectedMsg.comments_count];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:msg forKey:@"changedMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"msgChangedNoti" object:self userInfo:userInfo];
        
        [commentArr addObject:comment];
        [textView setText:@""];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:commentArr.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}
- (void)sendCommentMessage:(id)sender
{
    [self.view endEditing:YES];
}
@end

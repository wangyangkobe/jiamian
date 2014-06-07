//
//  MessageDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "TableHeaderView.h"

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
    //    UIImage *shareImage = [UIImage imageNamed:@"ic_share"];
    //    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    shareBtn.bounds = CGRectMake( 0, 0 , 44, 44 );
    //    [shareBtn setImage:shareImage forState:UIControlStateNormal];
    //    [shareBtn addTarget:self action:@selector(shareMsgBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *shareMessageBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
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
    CGFloat textHeight = [NSString textHeight:self.selectedMsg.text
                                 sizeWithFont:[UIFont systemFontOfSize:18]
                            constrainedToSize:CGSizeMake(260, 9999)];
    //    CGRect labelRect = myHeader.textLabel.frame;
    //    [myHeader.textLabel setFrame:CGRectMake(labelRect.origin.x, labelRect.origin.y, 260, textHeight)];
    
    if (_selectedMsg.background_url)
    {
        headerViewHeight = SCREEN_WIDTH;
    }
    else
    {
        headerViewHeight = textHeight + 60 + 60;
        if (IOS_NEWER_OR_EQUAL_TO_7)
            headerViewHeight += 10;
    }
    
    CGRect headerFrame = myHeader.frame;
    headerFrame.size.height = headerViewHeight;
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
    
    if (_selectedMsg.background_url)
    {
        [myHeader.backgroudImageView setImage:[UIImage imageNamed:@"blackalpha"]];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL* imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?imageView/2/w/%d/h/%d",
                                                _selectedMsg.background_url, (int)SCREEN_WIDTH, (int)SCREEN_WIDTH]];
        [manager downloadWithURL:imageUrl
                         options:0
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image && finished)
                           {
                               [myHeader setBackgroundColor:[UIColor colorWithPatternImage:image]];
                           }
                       }];
    }
    else
    {
        int bgImageNo = self.selectedMsg.background_no;
        if ( (1 == bgImageNo) || (2 == bgImageNo) )
        {
            [myHeader.commentImageView setImage:[UIImage imageNamed:@"comment_grey"]];
            [myHeader.areaLabel setTextColor:UIColorFromRGB(0x969696)];
            [myHeader.commentNumLabel setTextColor:UIColorFromRGB(0x969696)];
            [myHeader.likeNumberLabel setTextColor:UIColorFromRGB(0x969696)];
            [myHeader.visibleNumberLabel setTextColor:UIColorFromRGB(0x969696)];
            [myHeader.textLabel setTextColor:UIColorFromRGB(0x000000)];
            [myHeader setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            if (2 == bgImageNo) {
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"congruent_pentagon"]];
                [myHeader setBackgroundColor:picColor];
            } else {
                [myHeader setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
            [myHeader.likeImageView setImage:[UIImage imageNamed:@"ic_like_grey"]];
            [myHeader.visibleImageView setImage:[UIImage imageNamed:@"ic_eyes_grey"]];
        }
        else
        {
            [myHeader.commentImageView setImage:[UIImage imageNamed:@"comment_white"]];
            [myHeader.areaLabel setTextColor:UIColorFromRGB(0xffffff)];
            [myHeader.commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
            [myHeader.likeNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
            [myHeader.visibleNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
            [myHeader.textLabel setTextColor:UIColorFromRGB(0xffffff)];
            [myHeader setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            if (9 == bgImageNo) {
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food"]];
                [myHeader setBackgroundColor:picColor];
            } else {
                [myHeader setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
            [myHeader.likeImageView setImage:[UIImage imageNamed:@"ic_like"]];
            [myHeader.visibleImageView setImage:[UIImage imageNamed:@"ic_eyes"]];
        }
    }
    
    if (self.selectedMsg.has_like)
    {
        [myHeader.likeImageView  setImage:[UIImage imageNamed:@"ic_liƒked"]];
    }
    
    [myHeader.likeImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageTap:)];
    [likeImageTap setNumberOfTapsRequired:1];
    [myHeader.likeImageView addGestureRecognizer:likeImageTap];
    
    return myHeader;
}
- (void)likeImageTap:(UITapGestureRecognizer*)gestureRecognizer{
    if (self.selectedMsg.has_like)
        return;
    TableHeaderView* headerView = (TableHeaderView*)[gestureRecognizer.view superview];
    [headerView.likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    [headerView.likeNumberLabel setText:[NSString stringWithFormat:@"%d", self.selectedMsg.likes_count + 1]];
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:self.selectedMsg.message_id];
    if (message) {
        self.selectedMsg = message;
        if (message.is_official == NO){
            headerView.visibleNumberLabel.text = [NSString stringWithFormat:@"%d", message.visible_count];
        }
    }
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
        timeLabel.text = [NSString stringWithFormat:@"%d楼  %@", (int)indexPath.row + 1, [NSString convertTimeFormat:currentComment.create_at]];
    
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
    
    // view hierachy
   // [self.toolBar addSubview:imageView];
    [self.toolBar addSubview:textView];
   // [self.toolBar addSubview:entryImageView];
    
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
//Code from Brett Schumann
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
        CommentModel* comment = [[NetWorkConnect sharedInstance] commentCreate:self.selectedMsg.message_id text:textView.text];
        if (comment)
        {
            [commentArr addObject:comment];
            [textView setText:@""];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:commentArr.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    }
}
- (void)sendCommentMessage:(id)sender
{
    [self.view endEditing:YES];
}
@end

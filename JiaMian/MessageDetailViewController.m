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
#import "UIActionSheet+Blocks.h"
#import "ChatViewController.h"
#import "RNBlurModalView.h"
#import <QuartzCore/QuartzCore.h>

#define kCommentCellHeadImage  6000
#define kCommentCellTextLabel  6001
#define kCommentCellTimeLabel  6002

#define kVoteCellTextLabel     6003
@interface MessageDetailViewController () <UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>
{
    CGFloat headerViewHeight;
    NSMutableArray* commentArr;
    int i;
    HPGrowingTextView *textView;
    UIButton* sendButton;  //发送按钮
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray* messageArray;
}
@property (nonatomic, strong) UIView* footerView;
@property (nonatomic, strong) UIButton* sendBtn;
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
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(SCREEN_WIDTH * 0.5,  370);
    activityIndicator.hidesWhenStopped = YES;
    [self.tableView addSubview:activityIndicator];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    commentArr = [NSMutableArray array];
    [activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        long msgId = self.selectedMsg.message_id;
        NSArray* requestRes = [[NetWorkConnect sharedInstance] commentShowByMsgId:msgId sinceId:0 maxId:INT_MAX count:INT_MAX];
        [commentArr addObjectsFromArray:requestRes];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            if (commentArr.count == 0)
                self.tableView.tableFooterView = self.footerView;
            else
                self.tableView.tableFooterView = nil;
            [self.tableView reloadData];
        });
    });
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
- (UIView*)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 40)];
        UILabel* footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 40)];
        footerLabel.text = @"还没有评论，来一发?";
        footerLabel.textColor=UIColorFromRGB(0xadb0b2);
        footerLabel.textAlignment = NSTextAlignmentCenter;
        [_footerView addSubview:footerLabel];
    }
    return _footerView;
}
- (void)shareMsgBtnPressed:(id)sender
{
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
    if (_selectedMsg.is_official)
    {
        myHeader.areaLabel.text = @"假面官方团队";
    }
    
    if (_selectedMsg.background_url && _selectedMsg.background_url.length > 0)
    {
        [myHeader.bgImageView setImageWithURL:[NSURL URLWithString:_selectedMsg.background_url] placeholderImage:nil];
    }
    else
    {
        [myHeader.bgImageView setImage:nil];
        int bgImageNo = self.selectedMsg.background_no2;
        NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d@2x.jpg", bgImageNo];
        [myHeader.bgImageView setImage:[UIImage imageNamed:imageName]];
        
        
        [myHeader.commentImageView setImage:[UIImage imageNamed:@"comment_white"]];
        [myHeader.areaLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.likeNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.textLabel setTextColor:UIColorFromRGB(0xffffff)];
        [myHeader.likeImageView setImage:[UIImage imageNamed:@"ic_like"]];
    }
    if (self.selectedMsg.has_like)
    {
        [myHeader.likeImageView  setImage:[UIImage imageNamed:@"ic_liked"]];
    }
    
    [myHeader.likeImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageTap:)];
    [likeImageTap setNumberOfTapsRequired:1];
    [myHeader.likeImageView addGestureRecognizer:likeImageTap];
    
    [myHeader.moreView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *moreImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDemoButton:)];
    [moreImageTap setNumberOfTapsRequired:1];
    [myHeader.moreView addGestureRecognizer:moreImageTap];
    
    UITapGestureRecognizer* hiddenKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
    [hiddenKeyBoard setNumberOfTapsRequired:1];
    [myHeader addGestureRecognizer:hiddenKeyBoard];
    [hiddenKeyBoard setCancelsTouchesInView:NO];
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
    
    //爱心特效
    headerView.likeImageView.layer.contents = (id)[UIImage imageNamed:(i%2==0?@"2":@"1")].CGImage;
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(1.5)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    
    i++;
    [headerView.likeImageView.layer addAnimation:k forKey:@"SHOW"];
    [headerView.likeImageView setImage:[UIImage imageNamed:@"ic_liked.png"]];
    [headerView.likeNumberLabel setText:[NSString stringWithFormat:@"%d", self.selectedMsg.likes_count + 1]];
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:self.selectedMsg.message_id];
    if (message)
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:message forKey:@"changedMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"msgChangedNoti" object:self userInfo:userInfo];
        self.selectedMsg = message;
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
    if (_selectedMsg.votes.count == 0)
        return 1;
    else
        return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( (section == 0) && (_selectedMsg.votes.count != 0) ) {
        return _selectedMsg.votes.count;
    }
    
    return commentArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( (indexPath.section == 0) && (_selectedMsg.votes.count != 0) )
    {
        static NSString* CellIdentifier = @"VoteCellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        VoteModel* vote = (VoteModel*)[_selectedMsg.votes objectAtIndex:indexPath.row];
        UILabel* voteLabel = (UILabel*)[cell.contentView viewWithTag:kVoteCellTextLabel];
        [voteLabel setText:vote.content];
        return cell;
    }
    else
    {
        CommentModel* currentComment = (CommentModel*)[commentArr objectAtIndex:indexPath.row];
        static NSString* CellIdentifier = @"CommentCellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( (indexPath.section == 0) && (_selectedMsg.votes.count != 0) )
    {
        return 50;
    }
    else
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
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( (indexPath.section == 0) && (_selectedMsg.votes.count != 0))
    {
        // TODO: 这里对点击投票选项做处理
        return;
    }
    
    NSString* huanXinId = [[NSUserDefaults standardUserDefaults] objectForKey:kSelfHuanXinId];
    CommentModel* currComment = [commentArr objectAtIndex:indexPath.row];
    HxUserModel* hxUserInfo = [[NetWorkConnect sharedInstance] userGetByCommentId:currComment.comment_id];
    if ( [hxUserInfo.user.easemob_name isEqualToString:huanXinId] ) {
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [UIActionSheet showInView:self.tableView
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[ @"回复", @"私信" ]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         
                         if (0 == buttonIndex) {
                             TiXingViewController* tiXingVC = [[TiXingViewController alloc] init];
                             tiXingVC.selectSegementIndex = buttonIndex;
                             [self.navigationController pushViewController:tiXingVC animated:YES];
                         } else if(1 == buttonIndex) {
                             ChatViewController* chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishSiXinVCIndentifier"];
                             
                             chatVC.chatter = hxUserInfo.user.easemob_name;
                             chatVC.myHeadImage = hxUserInfo.my_head_image;
                             chatVC.chatterHeadImage = hxUserInfo.chat_head_image;
                             chatVC.customFlag = currComment.message_id;
                             chatVC.message = self.selectedMsg;
                             [self.navigationController pushViewController:chatVC animated:YES];
                         }
                         
                     }];
}
- (void)configureToolBar
{
    self.toolBar.backgroundColor=[UIColor whiteColor];
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 4, 270, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"匿名发表评论";
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textView.layer.borderColor = [UIColor whiteColor].CGColor;
    //  textView.layer.borderWidth = 1.0;
    //  textView.layer.cornerRadius =5.0;
    
    [self.toolBar addSubview:textView];
    
	_sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_sendBtn.frame = CGRectMake(self.toolBar.frame.size.width - 55, 0, 63, 40);
    _sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[sendBtn setTitle:@"评论" forState:UIControlStateNormal];
    [_sendBtn setImage:[UIImage imageNamed:@"feiji.png"] forState:UIControlStateNormal];
    
    [_sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    _sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
	[self.toolBar addSubview:_sendBtn];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //给键盘注册通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 监听键盘的显示与隐藏
- (void)keyboardWillShow:(NSNotification*)note {
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

- (void)keyboardWillHide:(NSNotification *)note {
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
    [_sendBtn setImage:[UIImage imageNamed:@"feiji-after.png"] forState:UIControlStateHighlighted];
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
        self.tableView.tableFooterView = nil;
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

- (IBAction)onDemoButton:(id)sender {
    RNBlurModalView *modal;
    UIView *moreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    moreView.backgroundColor = [UIColor whiteColor];
    moreView.layer.cornerRadius = 3.f;
    modal = [[RNBlurModalView alloc] initWithViewController:self view:moreView];
    [modal show];
    
    NSArray* btnTitles = @[@"私信", @"分享", @"举报"];
    for (NSInteger k = 0; k < btnTitles.count; k++) {
        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, k* 50, 200, 50)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:btnTitles[k] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleMoreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:button];
    }
    
    for (NSInteger k = 1; k <= 2; ++k) {
        UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 50 * k, 180, 1.0f)];
        [lineView setBackgroundColor:[UIColor lightGrayColor]];
        [moreView addSubview:lineView];
    }
}

- (void)handleMoreBtnAction:(UIButton*)sender
{
    UITableViewCell* cell = [UIView tableViewCellFromView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MessageModel* currentMsg = [messageArray objectAtIndex:indexPath.row];
    NSString* btnTitle = sender.titleLabel.text;
    if ([btnTitle isEqual:@"分享"])
    {
        NSString* shareText = [NSString stringWithFormat:@"\"%@\", 分享自%@, @假面App http://t.cn/8sk83lK",
                               currentMsg.text, currentMsg.area.area_name];
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMengAppKey
                                          shareText:shareText
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, nil]
                                           delegate:nil];
    }
    else if ([btnTitle isEqual:@"私信"]) {
        HxUserModel* hxUserInfo = [[NetWorkConnect sharedInstance] userGetByMsgId:currentMsg.message_id];
        ChatViewController* chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishSiXinVCIndentifier"];
        
        chatVC.chatter = hxUserInfo.user.easemob_name;
        chatVC.myHeadImage = hxUserInfo.my_head_image;
        chatVC.chatterHeadImage = hxUserInfo.chat_head_image;
        chatVC.customFlag = currentMsg.message_id;
        [self.navigationController pushViewController:chatVC animated:YES];
        
    } else {
        [UIActionSheet showInView:self.tableView
                        withTitle:@"举报"
                cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:nil
                otherButtonTitles:@[@"举报消息", @"举报用户"]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (0 == buttonIndex) {
                                 [[NetWorkConnect sharedInstance] reportMessageByMsgId:currentMsg.message_id];
                             } else if (1 == buttonIndex) {
                                 [[NetWorkConnect sharedInstance] reportUserByMsgId:currentMsg.message_id];
                             }
                         }];
    }
    
}


@end

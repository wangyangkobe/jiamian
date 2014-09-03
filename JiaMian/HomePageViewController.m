//
//  HomePageViewController.m
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "HomePageViewController.h"
#import "PublishMsgViewController.h"
#import "MessageDetailViewController.h"
#import "CommonMarco.h"
#import "UILabel+Extensions.h"
#import "UMFeedback.h"
#import "MsgTableViewCell.h"


#define kTopicTextLabel   8999
#define kTopicImageView   8994
#define kTopicNumberLabel 8993
#define kFaYanBtnTag      8990
#define kTouPiaoBtnTag    8991
static NSString* msgCellIdentifier = @"MsgTableViewCellIdentifier";

@interface HomePageViewController () <PullTableViewDelegate, UITableViewDelegate, UITableViewDataSource, MsgTableViewCellDelegate>
{
    NSMutableArray* messageArray;
    UIView* parentView;
    UIImageView* plusImageView;
    
    BOOL flag; //是否点击加号
}
@property (strong, nonatomic) UIView* moreBtnView;
@property (strong, nonatomic) UIButton* fayanBtn;
@property (strong, nonatomic) UIButton* toupiaoBtn;
@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (UIButton*)fayanBtn {
    if (_fayanBtn == nil) {
        _fayanBtn =[[UIButton alloc]initWithFrame:CGRectMake(50, 0, 50, 50)];
        [_fayanBtn addTarget:self action:@selector(handleBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_fayanBtn setTitle:@"发言" forState:UIControlStateNormal];
        [_fayanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fayanBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        _fayanBtn.tag = kFaYanBtnTag;
        _fayanBtn.backgroundColor=[UIColor clearColor];
    }
    return _fayanBtn;
}
- (UIButton*)toupiaoBtn {
    if (_toupiaoBtn == nil) {
        _toupiaoBtn =[[UIButton alloc]initWithFrame:CGRectMake(100, 0, 50, 50)];
        [_toupiaoBtn addTarget:self action:@selector(handleBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_toupiaoBtn setTitle:@"投票" forState:UIControlStateNormal];
        [_toupiaoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _toupiaoBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        _toupiaoBtn.tag = kTouPiaoBtnTag;
        _toupiaoBtn.backgroundColor=[UIColor clearColor];
    }
    return _toupiaoBtn;
}
- (void)handleBtnPressed:(UIButton*)sender {
    [self handlePlusTapped];
    PublishMsgViewController* publishVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishMsgVCIdentifier"];
    publishVC.isTouPiao = (sender.tag == kTouPiaoBtnTag);
    [self.navigationController pushViewController:publishVC animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    [self.pullTableView registerNib:[UINib nibWithNibName:@"MsgTableViewCell" bundle:nil] forCellReuseIdentifier:msgCellIdentifier];
    
    [self fetchDataFromServer];
    [[NetWorkConnect sharedInstance] messageForCategotry:1 categoryId:3 sinceId:0 maxId:INT_MAX count:15];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable)
                                                 name:@"publishMessageSuccess"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchDataFromServerForAreaChange)
                                                 name:@"changeAreaSuccess"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMsgChanged:) name:@"msgChangedNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoteNotification:)
                                                 name:@"showRomoteNotification"
                                               object:nil];
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[USER_DEFAULT objectForKey:kSelfHuanXinId]
                                                        password:[USER_DEFAULT objectForKey:kSelfHuanXinPW]
                                                      completion:nil onQueue:nil];
    
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.pullTableView addGestureRecognizer:recognizer];
    
    parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 280, 50, 50)];
    parentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    plusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 280, 50, 50)];
    [plusImageView setImage:[UIImage imageNamed:@"plus.png"]];
    [plusImageView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:parentView];
    [self.view addSubview:plusImageView];
    UITapGestureRecognizer* plusTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlusTapped)];
    plusTapGesture.numberOfTapsRequired = 1;
    [plusImageView setUserInteractionEnabled:YES];
    [plusImageView addGestureRecognizer:plusTapGesture];
}
- (void)handlePlusTapped
{
    if (NO == flag)
    {
        [UIView transitionWithView:parentView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            parentView.frame = CGRectMake(0, 280, 150, 50);
                            plusImageView.transform = CGAffineTransformMakeRotation(0.8);
                            [parentView addSubview:self.fayanBtn];
                            [parentView addSubview:self.toupiaoBtn];
                        } completion:^(BOOL finish){
                            flag = YES;
                        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            plusImageView.transform = CGAffineTransformMakeRotation(0);
            [self.fayanBtn removeFromSuperview];
            [self.toupiaoBtn removeFromSuperview];
            parentView.frame = CGRectMake(0, 280, 50, 50);
        } completion:^(BOOL finished) {
            flag = NO;
        }];
    }
}
- (void)handleSwipeLeft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.pullTableView];
    NSIndexPath *indexPath = [self.pullTableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.pullTableView cellForRowAtIndexPath:indexPath];
    [cell.contentView addSubview:self.moreBtnView];
}
- (UIView*)moreBtnView
{
    if (_moreBtnView == nil) {
        _moreBtnView = [[UIView alloc] initWithFrame:CGRectMake(240, 0, 320, 320)];
        [_moreBtnView setBackgroundColor:[UIColor lightGrayColor]];
        UIButton* shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setFrame:CGRectMake(10, 30, 60, 60)];
        shareBtn.layer.cornerRadius = 30;
        [shareBtn setBackgroundColor:[UIColor redColor]];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(handleMoreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtnView addSubview:shareBtn];
        
        UIButton* privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [privateBtn setFrame:CGRectMake(10, 130, 60, 60)];
        privateBtn.layer.cornerRadius = 30;
        [privateBtn setBackgroundColor:[UIColor redColor]];
        [privateBtn setTitle:@"私信" forState:UIControlStateNormal];
        [privateBtn addTarget:self action:@selector(handleMoreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtnView addSubview:privateBtn];
        
        UIButton* juBaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [juBaoBtn setFrame:CGRectMake(10, 230, 60, 60)];
        juBaoBtn.layer.cornerRadius = 30;
        [juBaoBtn setBackgroundColor:[UIColor redColor]];
        [juBaoBtn setTitle:@"举报" forState:UIControlStateNormal];
        [juBaoBtn addTarget:self action:@selector(handleMoreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtnView addSubview:juBaoBtn];
    }
    return _moreBtnView;
}
- (void)handleMoreBtnAction:(UIButton*)sender
{
    UITableViewCell* cell = [UIView tableViewCellFromView:sender];
    NSIndexPath *indexPath = [self.pullTableView indexPathForCell:cell];
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
        ChaViewController* chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishSiXinVCIndentifier"];
        
        chatVC.chatter = hxUserInfo.user.easemob_name;
        chatVC.myHeadImage = hxUserInfo.my_head_image;
        chatVC.chatterHeadImage = hxUserInfo.chat_head_image;
        chatVC.customFlag = currentMsg.message_id;
        [self.navigationController pushViewController:chatVC animated:YES];
        
    } else {
        [UIActionSheet showInView:self.pullTableView
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
    [_moreBtnView removeFromSuperview];
}
#pragma mark - MsgTableViewCellDelegate
- (void)removeMoreBtnViewFromCell
{
    [self.moreBtnView removeFromSuperview];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.moreBtnView removeFromSuperview];
}
- (void)handleRemoteNotification:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSInteger msgId = [[userInfo valueForKey:@"message_id"] integerValue];
    
    NSLog(@"%s, msgId = %ld", __FUNCTION__, (long)msgId);
    MessageModel* msg = [[NetWorkConnect sharedInstance] messageShowByMsgId:msgId];
    if (msg)
    {
        MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
        msgDetailVC.selectedMsg = msg;
        [self.navigationController pushViewController:msgDetailVC animated:YES];
    }
}
- (void)handleMsgChanged:(NSNotification*)notification
{
    MessageModel* tappedMsg = (MessageModel*)[notification.userInfo objectForKey:@"changedMsg"];
    NSUInteger index = [messageArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MessageModel* msg = (MessageModel*)obj;
        return msg.message_id == tappedMsg.message_id;
    }];
    if (index != NSNotFound)
    {
        [messageArray replaceObjectAtIndex:index withObject:tappedMsg];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pullTableView reloadData];
    });
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
- (void)fetchDataFromServer
{
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 50)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    
    messageArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:0
                                                                   sinceId:0
                                                                     maxId:INT_MAX
                                                                     count:20
                                                                  trimArea:NO
                                                                filterType:0];
        [messageArray addObjectsFromArray:requestRes];
        
        // type = 1-热门话题
        requestRes = [[NetWorkConnect sharedInstance] topicList:0 maxId:INT_MAX type:1 count:3];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.pullTableView reloadData];
        });
    });
}
- (void)fetchDataFromServerForAreaChange
{
    messageArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:0
                                                                   sinceId:0
                                                                     maxId:INT_MAX
                                                                     count:20
                                                                  trimArea:NO
                                                                filterType:0];
        [messageArray addObjectsFromArray:requestRes];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.pullTableView reloadData];
        });
    });
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgTableViewCell* cell = (MsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:msgCellIdentifier
                                                                                 forIndexPath:indexPath];
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    cell.msgTextLabel.text = currentMsg.text;
    cell.areaLabel.text = currentMsg.area.area_name;
    cell.commentNumLabel.text = [NSString stringWithFormat:@"%d", currentMsg.comments_count];
    cell.likeNumLabel.text = [NSString stringWithFormat:@"%d", currentMsg.likes_count];
    if (currentMsg.is_official)
    {
        cell.likeNumLabel.text = @"all";
        cell.areaLabel.text = @"假面官方团队";
    }
    [cell.likeImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(likeImageTap:)];
    [likeImageTap setNumberOfTapsRequired:1];
    [cell.likeImageView addGestureRecognizer:likeImageTap];
    
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    MsgTableViewCell* msgCell = (MsgTableViewCell*)cell;
    if (currentMsg.background_url && currentMsg.background_url.length > 0)
    {
        [msgCell.bgImageView setImageWithURL:[NSURL URLWithString:currentMsg.background_url] placeholderImage:nil];
        UIImage* maskImage = [UIImage imageNamed:@"blackalpha.png"];
        [msgCell.blackImageView setBackgroundColor:[UIColor colorWithPatternImage:maskImage]];
    }
    else
    {
        [msgCell.blackImageView setBackgroundColor:[UIColor clearColor]];
        [msgCell.bgImageView setImage:nil];
        int bgImageNo = currentMsg.background_no2;
        if (bgImageNo >=1 && bgImageNo <= 10) {
            [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
        } else {
            NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d.png", bgImageNo];
            UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
            [cell.contentView setBackgroundColor:picColor];
        }
    }
    
    [msgCell.commentImageView setImage:[UIImage imageNamed:@"comment_white"]];
    [msgCell.likeImageView setImage:[UIImage imageNamed:@"ic_like"]];
    if (currentMsg.has_like)
    {
        [msgCell.likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    msgDetailVC.selectedMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:msgDetailVC animated:YES];
}
#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.5f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:3.0f];
}

#pragma mark - Refresh and load more methods
- (void)refreshTable
{
    if (0 == [messageArray count])
        return;
    self.pullTableView.pullTableIsRefreshing = YES;
    long sinceId = ((MessageModel*)messageArray[0]).message_id;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* newMessages = [[NetWorkConnect sharedInstance] messageList:0
                                                                    sinceId:sinceId
                                                                      maxId:INT_MAX
                                                                      count:20
                                                                   trimArea:NO
                                                                 filterType:0];
        for (MessageModel* message in [newMessages reverseObjectEnumerator]){
            [messageArray insertObject:message atIndex:0];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( _pullTableView.pullTableIsRefreshing )
            {
                _pullTableView.pullLastRefreshDate = [NSDate date];
                _pullTableView.pullTableIsRefreshing = NO;
                [_pullTableView reloadData];
            }
        });
    });
}

- (void)loadMoreDataToTable
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MessageModel* lastMessage = [messageArray lastObject];
        NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] messageList:0
                                                                    sinceId:0
                                                                      maxId:lastMessage.message_id
                                                                      count:20
                                                                   trimArea:NO
                                                                 filterType:0];
        __block NSInteger fromIndex = [messageArray count];
        [messageArray addObjectsFromArray:loadMoreRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            
            for(id result __unused in loadMoreRes)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:fromIndex inSection:0]];
                fromIndex++;
            }
            
            [_pullTableView beginUpdates];
            [_pullTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [_pullTableView endUpdates];
            if (indexPaths.count > 0)
                [_pullTableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            self.pullTableView.pullTableIsLoadingMore = NO;
        });
    });
}

- (IBAction)publishMessage:(id)sender
{
    NSDictionary* msgLimmit = [[NetWorkConnect sharedInstance] userMessageLimit];
    
    if (nil == msgLimmit)
        return;
    if( [[msgLimmit objectForKey:@"remain_count"] integerValue] > 0 )
    {
        PublishMsgViewController* publisMsgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishMsgVCIdentifier"];
        [self.navigationController pushViewController:publisMsgVC animated:YES];
    }
    else
    {
        AlertContent(@"为了保证社区纯净，您每天发布次数有限，今天已达上限");
    }
}

- (void)likeImageTap:(UITapGestureRecognizer*)gestureRecognizer
{
    MsgTableViewCell* tappedCell = (MsgTableViewCell*)[UIView tableViewCellFromTapGestture:gestureRecognizer];
    
    NSIndexPath* tapIndexPath = [self.pullTableView indexPathForCell:tappedCell];
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:tapIndexPath.row];
    if (currentMsg.has_like)
        return;
    
    [tappedCell.likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    tappedCell.likeNumLabel.text = [NSString stringWithFormat:@"%d", currentMsg.likes_count + 1];
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:currentMsg.message_id];
    if (message)
    {
        if (message.is_official == NO)
        {
            [UIView animateForVisibleNumberInView:tappedCell.contentView];
        }
        [messageArray replaceObjectAtIndex:tapIndexPath.row withObject:message];
    }
}
@end

//
//  HomePageViewController.m
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "HomePageViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "PublishMsgViewController.h"
#import "MessageDetailViewController.h"
#import "UnReadMsgViewController.h"
#import "LogInViewController.h"
#import "CommonMarco.h"
#import "UILabel+Extensions.h"
#import "UMFeedback.h"
#import "SelectAreaViewController.h"

#define kTextLabel    8000
#define kAreaLabel    8001
#define kCommentLabel 8002
#define kCommentImage 8003
#define kLikeImage    8004
#define kLikeNumberLabel 8005
#define kVisibleImage 8006
#define kVisibleNumberLabel 8007
#define kJuBaoBtn     8008

@interface HomePageViewController () <PullTableViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray* messageArray;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"假面校园";
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    [self fetchDataFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable)
                                                 name:@"publishMessageSuccess"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchDataFromServer)
                                                 name:@"changeAreaSuccess"
                                               object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    
    //创建BarButtonItem
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [customButton addTarget:self action:@selector(unReadMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        [customButton setImage:[UIImage imageNamed:@"ico-to-do-list_ios7"] forState:UIControlStateNormal];
    } else {
        [customButton setImage:[UIImage imageNamed:@"ico-to-do-list"] forState:UIControlStateNormal];
    }
    
    BBBadgeBarButtonItem *unReadMsgBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    unReadMsgBarButton.shouldHideBadgeAtZero = YES;
    unReadMsgBarButton.badgeOriginX = 5;
    unReadMsgBarButton.badgeOriginY = -9;
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(settingBtnPressed:)];;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settingBarButton, unReadMsgBarButton, nil]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        long unreadCount = [[NetWorkConnect sharedInstance] notificationUnreadCount];
        dispatch_sync(dispatch_get_main_queue(), ^{
            unReadMsgBarButton.badgeValue = [NSString stringWithFormat:@"%ld", unreadCount];
        });
        
    });
}
- (void)fetchDataFromServer
{
    messageArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        long areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:areaId
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
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)settingBtnPressed:(id)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"邀请朋友" image:nil target:self action:@selector(menuItemPressed:)],
      [KxMenuItem menuItem:@"选择校园" image:nil target:self action:@selector(menuItemPressed:)],
      [KxMenuItem menuItem:@"意见反馈" image:nil target:self action:@selector(menuItemPressed:)],
     // [KxMenuItem menuItem:@"检查更新" image:nil target:self action:@selector(menuItemPressed:)],
      [KxMenuItem menuItem:@"注销登录" image:nil target:self action:@selector(menuItemPressed:)],
      ];
    
    for (KxMenuItem* item in menuItems)
        item.alignment = NSTextAlignmentCenter;
    
    [KxMenu setTintColor:[UIColor whiteColor]];
    UIWindow* window = [[UIApplication sharedApplication].delegate window];
    [KxMenu showMenuInView:window fromRect:CGRectMake(290, 30, 30, 30) menuItems:menuItems];
}
- (void)menuItemPressed:(id)sender
{
    KxMenuItem* menuItem = (KxMenuItem*)sender;
    if ([menuItem.title isEqualToString:@"邀请朋友"])
    {
        //[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, nil]
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMengAppKey
                                          shareText:@"亲，来玩玩假面吧!下载链接:http://www.jiamiantech.com"
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, nil]
                                           delegate:nil];
    }
    else if([menuItem.title isEqualToString:@"选择校园"])
    {
        SelectAreaViewController* selectAreaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAreaVCIdentifier"];
        selectAreaVC.firstSelect = NO;
        [[UIApplication sharedApplication].keyWindow setRootViewController:selectAreaVC];
    }
    else if([menuItem.title isEqualToString:@"意见反馈"])
    {
        [UMFeedback showFeedback:self withAppkey:kUMengAppKey];
    }
    else if([menuItem.title isEqualToString:@"检查更新"])
    {
        [MobClick checkUpdate:@"New version" cancelButtonTitle:@"Skip" otherButtonTitles:@"Goto Store"];
    }
    else
    {
        BOOL result = [[NetWorkConnect sharedInstance] userLogOut];
        if (result)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            LogInViewController* logInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:logInVC];
        }
    }
}
-(void)unReadMessagePressed:(id)sender
{
    NSLog(@"Bar Button Item Pressed");
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItems[1];
    barButton.badgeValue = @"0";
    barButton.shouldHideBadgeAtZero = YES;
    
    UnReadMsgViewController* unReadMsgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UnReadMsgVCIdentifier"];
    [self.navigationController pushViewController:unReadMsgVC animated:YES];
}
#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s %lu", __FUNCTION__, (unsigned long)messageArray.count);
    return [messageArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString* text = [(MessageModel*)[messageArray objectAtIndex:row] text];
    CGFloat textHeight = [NSString textHeight:text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(260,9999)];
    //    CGFloat textHeight = [text  sizeWithFont:[UIFont systemFontOfSize:18]
    //                           constrainedToSize:CGSizeMake(260, 42*10)
    //                               lineBreakMode:NSLineBreakByWordWrapping].height;
    if (IOS_NEWER_OR_EQUAL_TO_7)
        return textHeight + 60 + 60 + 10;
    else
        return textHeight + 60 + 60;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"TextCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    };
    UILabel* textLabel          = (UILabel*)[cell.contentView viewWithTag:kTextLabel];
    UILabel* areaLabel          = (UILabel*)[cell.contentView viewWithTag:kAreaLabel];
    UILabel* likeNumerLabel     = (UILabel*)[cell.contentView viewWithTag:kLikeNumberLabel];
    UILabel* commentNumLabel    = (UILabel*)[cell.contentView viewWithTag:kCommentLabel];
    UILabel* visibleNumberLabel = (UILabel*)[cell.contentView viewWithTag:kVisibleNumberLabel];
    
    UIImageView* likeImage    = (UIImageView*)[cell.contentView viewWithTag:kLikeImage];
    
    UIButton* juBaoBtn = (UIButton*)[cell.contentView viewWithTag:kJuBaoBtn];
    [juBaoBtn addTarget:self action:@selector(handleJuBao:) forControlEvents:UIControlEventTouchUpInside];
    
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    
    textLabel.text = currentMsg.text;
    areaLabel.text = currentMsg.area.area_name;
    commentNumLabel.text = [NSString stringWithFormat:@"%d", currentMsg.comments_count];
    likeNumerLabel.text = [NSString stringWithFormat:@"%d", currentMsg.likes_count];
    visibleNumberLabel.text = [NSString stringWithFormat:@"%d", currentMsg.visible_count];
    if (currentMsg.is_official)
    {
        visibleNumberLabel.text = @"all";
        areaLabel.text = @"假面官方团队";
    }
    [likeImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageTap:)];
    [likeImageTap setNumberOfTapsRequired:1];
    [likeImage addGestureRecognizer:likeImageTap];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    
    UILabel* textLabel       = (UILabel*)[cell.contentView viewWithTag:kTextLabel];
    UILabel* areaLabel       = (UILabel*)[cell.contentView viewWithTag:kAreaLabel];
    UILabel* commentNumLabel = (UILabel*)[cell.contentView viewWithTag:kCommentLabel];
    UILabel* likeNumerLabel  = (UILabel*)[cell.contentView viewWithTag:kLikeNumberLabel];
    UILabel* visibleNumberLabel = (UILabel*)[cell.contentView viewWithTag:kVisibleNumberLabel];
    
    UIImageView* commentImage = (UIImageView*)[cell.contentView viewWithTag:kCommentImage];
    UIImageView* likeImage    = (UIImageView*)[cell.contentView viewWithTag:kLikeImage];
    UIImageView* visibleImage = (UIImageView*)[cell.contentView viewWithTag:kVisibleImage];
    
    UIButton* juBaoBtn = (UIButton*)[cell.contentView viewWithTag:kJuBaoBtn];
    
    int bgImageNo = currentMsg.background_no;
    if ( (1 == bgImageNo) || (2 == bgImageNo) )
    {
        [commentImage setImage:[UIImage imageNamed:@"comment_grey"]];
        [likeImage setImage:[UIImage imageNamed:@"ic_like_grey"]];
        [visibleImage setImage:[UIImage imageNamed:@"ic_eyes_grey"]];
        [areaLabel setTextColor:UIColorFromRGB(0x969696)];
        [commentNumLabel setTextColor:UIColorFromRGB(0x969696)];
        [likeNumerLabel setTextColor:UIColorFromRGB(0x969696)];
        [visibleNumberLabel setTextColor:UIColorFromRGB(0x969696)];
        [juBaoBtn setTitleColor:UIColorFromRGB(0x969696) forState:UIControlStateNormal];
        [textLabel setTextColor:UIColorFromRGB(0x000000)];
        
        if (2 == bgImageNo)
        {
            UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"congruent_pentagon"]];
            [cell.contentView setBackgroundColor:picColor];
        }
        else
        {
            [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
        }
    }
    else
    {
        [commentImage setImage:[UIImage imageNamed:@"comment_white"]];
        [likeImage setImage:[UIImage imageNamed:@"ic_like"]];
        [visibleImage setImage:[UIImage imageNamed:@"ic_eyes"]];
        [areaLabel setTextColor:UIColorFromRGB(0xffffff)];
        [commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
        [likeNumerLabel setTextColor:UIColorFromRGB(0xffffff)];
        [visibleNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
        [juBaoBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [textLabel setTextColor:UIColorFromRGB(0xffffff)];
        if (9 == bgImageNo) {
            UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food"]];
            [cell.contentView setBackgroundColor:picColor];
        } else {
            [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
        }
    }
    if (currentMsg.has_like) {
        [likeImage setImage:[UIImage imageNamed:@"ic_liked"]];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
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
    NSLog(@"call: %s", __FUNCTION__);
    if (0 == [messageArray count])
        return;
    self.pullTableView.pullTableIsRefreshing = YES;
    long sinceId = ((MessageModel*)messageArray[0]).message_id;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        long areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
        NSArray* newMessages = [[NetWorkConnect sharedInstance] messageList:areaId
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
        NSInteger areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
        NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] messageList:areaId
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
    CGPoint tapLocation = [gestureRecognizer locationInView:self.pullTableView];
    NSIndexPath* tapIndexPath = [self.pullTableView indexPathForRowAtPoint:tapLocation];
    
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:tapIndexPath.row];
    
    if (currentMsg.has_like)
        return;
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:currentMsg.message_id];
    
    if (message)
    {
        UITableViewCell* tappedCell = [self.pullTableView cellForRowAtIndexPath:tapIndexPath];
        UIImageView* likeImageView = (UIImageView*)[tappedCell viewWithTag:kLikeImage];
        [likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
        UILabel* likeNumberLabel = (UILabel*)[tappedCell viewWithTag:kLikeNumberLabel];
        likeNumberLabel.text = [NSString stringWithFormat:@"%d", currentMsg.likes_count + 1];
        UILabel* visibleNumberLabel = (UILabel*)[tappedCell viewWithTag:kVisibleNumberLabel];
        if (message.is_official == NO)
        {
            visibleNumberLabel.text = [NSString stringWithFormat:@"%d", message.visible_count];
        }
        [messageArray replaceObjectAtIndex:tapIndexPath.row withObject:message];
    }
}
- (void)handleJuBao:(UIButton*)sender
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
@end

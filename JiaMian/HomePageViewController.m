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
#import "SelectZoneViewController.h"
#import "TopicDetailViewController.h"
#import "SettingViewController.h"
#import "MoreTopicViewController.h"

#define kTextLabel    8000
#define kAreaLabel    8001
#define kCommentLabel 8002
#define kCommentImage 8003
#define kLikeImage    8004
#define kLikeNumberLabel 8005
#define kVisibleImage 8006
#define kVisibleNumberLabel 8007
#define kBackgroundImageView 8008
#define kMaskImageView  8009
#define kTopicTextLabel   8999
//#define kTopicNumberLabel 8998
//#define kTopicView        8997
//#define kTopicMsgLabel    8996
//#define kTopicMsgView     8995
#define kTopicImageView   8994
#define kTopicNumberLabel 8993
@interface HomePageViewController () <PullTableViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray* messageArray;
    NSMutableArray* topicArray;
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
    
    self.title = @"假面";
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    [self fetchDataFromServer];
    
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
    NSLog(@"%s", __FUNCTION__);
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
    
    UIButton *publishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [publishButton setBackgroundImage:[UIImage imageNamed:@"publish_msg"] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(publishMessage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* publistBtnItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    [self.navigationItem setLeftBarButtonItem:publistBtnItem];
    
    //创建BarButtonItem
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [customButton addTarget:self action:@selector(unReadMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        [customButton setImage:[UIImage imageNamed:@"ico-to-do-list_ios7"] forState:UIControlStateNormal];
    } else {
        [customButton setImage:[UIImage imageNamed:@"ico-to-do-list_ios7"] forState:UIControlStateNormal];
    }
    
    BBBadgeBarButtonItem *unReadMsgBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    unReadMsgBarButton.shouldHideBadgeAtZero = YES;
    unReadMsgBarButton.badgeOriginX = 5;
    unReadMsgBarButton.badgeOriginY = -9;
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(showSettingVC)];
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        [settingBarButton setTintColor:[UIColor whiteColor]];
    }
    
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
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 50)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    
    messageArray = [NSMutableArray array];
    topicArray   = [NSMutableArray array];
    
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
        [topicArray addObjectsFromArray:requestRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.pullTableView reloadData];
        });
    });
}
- (void)fetchDataFromServerForAreaChange
{
    messageArray = [NSMutableArray array];
    topicArray   = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:0
                                                                   sinceId:0
                                                                     maxId:INT_MAX
                                                                     count:20
                                                                  trimArea:NO
                                                                filterType:0];
        [messageArray addObjectsFromArray:requestRes];
        
        requestRes = [[NetWorkConnect sharedInstance] topicList:0 maxId:INT_MAX type:1 count:3];
        [topicArray addObjectsFromArray:requestRes];
        
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
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)showSettingVC
{
    SettingViewController* settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingVCIdentifier"];
    [self.navigationController pushViewController:settingVC animated:YES];
}
//- (void)menuItemPressed:(id)sender
//{
//    KxMenuItem* menuItem = (KxMenuItem*)sender;
//    if ([menuItem.title isEqualToString:@"邀请朋友"])
//    {
//        //[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, nil]
//        [UMSocialSnsService presentSnsIconSheetView:self
//                                             appKey:kUMengAppKey
//                                          shareText:@"亲，来玩玩假面吧!下载链接:http://www.jiamiantech.com"
//                                         shareImage:nil
//                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, nil]
//                                           delegate:nil];
//    }
//    else if([menuItem.title isEqualToString:@"选择校园"])
//    {
//        SelectZoneViewController* selectAreaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAreaVCIdentifier"];
//        selectAreaVC.firstSelect = NO;
//        [[UIApplication sharedApplication].keyWindow setRootViewController:selectAreaVC];
//    }
//    else if([menuItem.title isEqualToString:@"意见反馈"])
//    {
//        [UMFeedback showFeedback:self withAppkey:kUMengAppKey];
//    }
//    else if([menuItem.title isEqualToString:@"检查更新"])
//    {
//        [MobClick checkUpdate:@"New version" cancelButtonTitle:@"Skip" otherButtonTitles:@"Goto Store"];
//    }
//    else if([menuItem.title isEqualToString:@"选择圈子"])
//    {
//        SelectZoneViewController* selectZoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectZoneVCIdentifier"];
//        selectZoneVC.firstSelect = NO;
//        [self presentViewController:selectZoneVC animated:YES completion:nil];
//    }
//    else
//    {
//        BOOL result = [[NetWorkConnect sharedInstance] userLogOut];
//        if (result)
//        {
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserLogIn];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            LogInViewController* logInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
//            [[UIApplication sharedApplication].keyWindow setRootViewController:logInVC];
//        }
//    }
//}
-(void)unReadMessagePressed:(id)sender
{
    NSLog(@"Bar Button Item Pressed");
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItems[1];
    barButton.badgeValue = @"0";
    barButton.shouldHideBadgeAtZero = YES;
    
    TiXingViewController* tiXinfVC = [[TiXingViewController alloc] init];
    tiXinfVC.selectSegementIndex = 0;
    [self.navigationController pushViewController:tiXinfVC animated:YES];
//    UnReadMsgViewController* unReadMsgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UnReadMsgVCIdentifier"];
//    [self.navigationController pushViewController:unReadMsgVC animated:YES];
}
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0){
        return [topicArray count];
    }else{
        return [messageArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 92;
    }else{
        return SCREEN_WIDTH;
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 90, 30)];
    view.backgroundColor = UIColorFromRGB(0xf4f4f4);
    label.backgroundColor = UIColorFromRGB(0xf4f4f4);
    //  view.opaque = NO;
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(110, 2, 40, 26)];
    [btn setBackgroundImage:[UIImage imageNamed:@"gointolist"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showMoreTopic:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:image];
    [view addSubview:label];
    
    if (section == 0) {
        [image setImage:[UIImage imageNamed:@"topic"]];
        [label setTextColor:UIColorFromRGB(0xfd5b00)];
        [view addSubview:btn];
        [label setText:@"  热门话题"];
    } else {
        [image setImage:[UIImage imageNamed:@"secret"]];
        [label setTextColor:UIColorFromRGB(0xffb50b)];
        [label setText:@"  圈内秘密"];
    }
    return view;
}
- (void)showMoreTopic:(id)sender
{
    MoreTopicViewController* moreTopicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MoreTopicVCIdentifier"];
    [self.navigationController pushViewController:moreTopicVC animated:YES];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
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
        UITapGestureRecognizer *likeImageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(likeImageTap:)];
        [likeImageTap setNumberOfTapsRequired:1];
        [likeImage addGestureRecognizer:likeImageTap];
        
        return cell;
    }
    else
    {
        static NSString* CellIdentifier = @"HotTopicCellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        };
        
        [cell setBackgroundColor:UIColorFromRGB(0xf7f6f4)];
        
        TopicModel* topic = (TopicModel*)[topicArray objectAtIndex:indexPath.row];
        UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:kTopicTextLabel];
        [textLabel setText:topic.topic_title];
        
        UILabel* numberLabel = (UILabel*)[cell.contentView viewWithTag:kTopicNumberLabel];
        [numberLabel setText:[NSString stringWithFormat:@"%d", topic.message_count]];
        [numberLabel setTextColor:UIColorFromRGB(0xfc5d20)];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_next"]];;
        [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
        
        UILabel* textLabel       = (UILabel*)[cell.contentView viewWithTag:kTextLabel];
        UILabel* areaLabel       = (UILabel*)[cell.contentView viewWithTag:kAreaLabel];
        UILabel* commentNumLabel = (UILabel*)[cell.contentView viewWithTag:kCommentLabel];
        UILabel* likeNumerLabel  = (UILabel*)[cell.contentView viewWithTag:kLikeNumberLabel];
        UILabel* visibleNumberLabel = (UILabel*)[cell.contentView viewWithTag:kVisibleNumberLabel];
        
        UIImageView* commentImage = (UIImageView*)[cell.contentView viewWithTag:kCommentImage];
        UIImageView* likeImage    = (UIImageView*)[cell.contentView viewWithTag:kLikeImage];
        UIImageView* visibleImage = (UIImageView*)[cell.contentView viewWithTag:kVisibleImage];
        UIImageView* bgImageView  = (UIImageView*)[cell.contentView viewWithTag:kBackgroundImageView];
        UIImageView* maskImageView  = (UIImageView*)[cell.contentView viewWithTag:kMaskImageView];
        
        if (currentMsg.background_url && currentMsg.background_url.length > 0)
        {
            [commentImage setImage:[UIImage imageNamed:@"comment_white"]];
            [likeImage setImage:[UIImage imageNamed:@"ic_like"]];
            [visibleImage setImage:[UIImage imageNamed:@"ic_eyes"]];
            [areaLabel setTextColor:UIColorFromRGB(0xffffff)];
            [commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
            [likeNumerLabel setTextColor:UIColorFromRGB(0xffffff)];
            [visibleNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
            [textLabel setTextColor:UIColorFromRGB(0xffffff)];
            
            [bgImageView setImageWithURL:[NSURL URLWithString:currentMsg.background_url] placeholderImage:nil];
            UIImage* maskImage = [UIImage imageNamed:@"blackalpha.png"];
            [maskImageView setBackgroundColor:[UIColor colorWithPatternImage:maskImage]];
            //[maskImageView setImage:[UIImage imageNamed:@"blackalpha.png"]];
        }
        else
        {
            [maskImageView setBackgroundColor:[UIColor clearColor]];
            [bgImageView setImage:nil];
            int bgImageNo = currentMsg.background_no2;
            if (bgImageNo >=1 && bgImageNo <= 10)
            {
                [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
            else
            {
                NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d.png", bgImageNo];
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
                [cell.contentView setBackgroundColor:picColor];
            }
            [commentImage setImage:[UIImage imageNamed:@"comment_white"]];
            [likeImage setImage:[UIImage imageNamed:@"ic_like"]];
            [visibleImage setImage:[UIImage imageNamed:@"ic_eyes"]];
            [areaLabel setTextColor:UIColorFromRGB(0xffffff)];
            [commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
            [likeNumerLabel setTextColor:UIColorFromRGB(0xffffff)];
            [visibleNumberLabel setTextColor:UIColorFromRGB(0xffffff)];
            [textLabel setTextColor:UIColorFromRGB(0xffffff)];
        }
        if (currentMsg.has_like)
        {
            [likeImage setImage:[UIImage imageNamed:@"ic_liked"]];
        }
    }
    else  //设置topic
    {
        TopicModel* topic = (TopicModel*)[topicArray objectAtIndex:indexPath.row];
        UIImageView* topicImageView = (UIImageView*)[cell.contentView viewWithTag:kTopicImageView];
        NSURL* imageUrl = [NSURL URLWithString:topic.img_url];
        [topicImageView setImageWithURL:imageUrl placeholderImage:nil];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
        msgDetailVC.selectedMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:msgDetailVC animated:YES];
    }
    else
    {
        TopicModel* topic = [topicArray objectAtIndex:indexPath.row];
        TopicDetailViewController* topicDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TopicDetailVCIdentifier"];
        topicDetailVC.topic = topic;
        [self.navigationController pushViewController:topicDetailVC animated:YES];
    }
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
        NSArray* topics = [[NetWorkConnect sharedInstance] topicList:0 maxId:INT_MAX type:1 count:3];
        NSInteger currentIndex = 0;
        for (TopicModel* element in topics) {
            if (currentIndex < 3) {
                [topicArray replaceObjectAtIndex:currentIndex withObject:element];
                currentIndex += 1;
            }
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
                [indexPaths addObject:[NSIndexPath indexPathForRow:fromIndex inSection:1]];
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
    UIImageView* tappedView = (UIImageView*)[gestureRecognizer view];
    UITableViewCell* tappedCell;
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        tappedCell = (UITableViewCell*)tappedView.superview.superview.superview;
    }else{
        tappedCell = (UITableViewCell*)tappedView.superview.superview;
    }
    
    NSIndexPath* tapIndexPath = [self.pullTableView indexPathForCell:tappedCell];
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:tapIndexPath.row];
    if (currentMsg.has_like)
        return;
    
    UIImageView* likeImageView = (UIImageView*)[tappedCell viewWithTag:kLikeImage];
    [likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    UILabel* likeNumberLabel = (UILabel*)[tappedCell viewWithTag:kLikeNumberLabel];
    likeNumberLabel.text = [NSString stringWithFormat:@"%d", currentMsg.likes_count + 1];
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageLikeByMsgId:currentMsg.message_id];
    if (message)
    {
        UILabel* visibleNumberLabel = (UILabel*)[tappedCell viewWithTag:kVisibleNumberLabel];
        if (message.is_official == NO)
        {
            [UIView animateForVisibleNumberInView:tappedCell.contentView];
            visibleNumberLabel.text = [NSString stringWithFormat:@"%d", message.visible_count];
        }
        [messageArray replaceObjectAtIndex:tapIndexPath.row withObject:message];
    }
}

- (void)configureTopicMsgView:(UIView*)view textLabel:(UILabel*)label message:(MessageModel*)message
{
    if (message.background_url && message.background_url.length > 0)
    {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL* imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?imageView/2/w/%d/h/%d/q/100",
                                                message.background_url, 92, 92]];
        [manager downloadWithURL:imageUrl
                         options:0
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image && finished)
                           {
                               [view setBackgroundColor:[UIColor colorWithPatternImage:image]];
                           }
                       }];
    }
    else
    {
        int bgImageNo = message.background_no;
        if ( (1 == bgImageNo) || (2 == bgImageNo) )
        {
            [label setTextColor:UIColorFromRGB(0x000000)];
            if (2 == bgImageNo)
            {
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"congruent_pentagon"]];
                [view setBackgroundColor:picColor];
            }
            else
            {
                [view setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
        }
        else
        {
            [label setTextColor:UIColorFromRGB(0xffffff)];
            if (9 == bgImageNo)
            {
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food"]];
                [view setBackgroundColor:picColor];
            }
            else
            {
                [view setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
        }
    }
}
@end

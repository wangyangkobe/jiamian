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

#define kTextLabel    8000
#define kAreaLabel    8001
#define kCommentLabel 8002
#define kCommentImage 8003

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
    self.title = @"假面校园";
    self.pullTableView.delegate = self;
    self.pullTableView.dataSource = self;
    self.pullTableView.pullDelegate = self;
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [customButton addTarget:self action:@selector(unReadMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [customButton setImage:[UIImage imageNamed:@"ico-to-do-list"] forState:UIControlStateNormal];
    BBBadgeBarButtonItem *unReadMsgBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    unReadMsgBarButton.shouldHideBadgeAtZero = YES;
    //unReadMsgBarButton.badgeValue = @"2";
    unReadMsgBarButton.badgeOriginX = 5;
    unReadMsgBarButton.badgeOriginY = -9;
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(settingBtnPressed:)];;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settingBarButton, unReadMsgBarButton, nil]];
    
    messageArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int unreadCount = [[NetWorkConnect sharedInstance] notificationUnreadCount];
        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:0
                                                                   sinceId:0
                                                                     maxId:INT_MAX
                                                                     count:20
                                                                  trimArea:NO
                                                                filterType:0];
        [messageArray addObjectsFromArray:requestRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            unReadMsgBarButton.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];
            [self.pullTableView reloadData];
        });
    });
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable)
                                                 name:@"publishMessageSuccess"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)settingBtnPressed:(id)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"邀请朋友" image:nil target:self action:@selector(menuItemPressed:)],
      [KxMenuItem menuItem:@"意见反馈" image:nil target:self action:@selector(menuItemPressed:)],
      [KxMenuItem menuItem:@"检查更新" image:nil target:self action:@selector(menuItemPressed:)],
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
    NSLog(@"%s", __FUNCTION__);
    KxMenuItem* menuItem = (KxMenuItem*)sender;
    if ([menuItem.title isEqualToString:@"邀请朋友"])
    {
        NSLog(@"邀请朋友");
    }
    else if([menuItem.title isEqualToString:@"意见反馈"])
    {
        
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
    NSLog(@"%s %d", __FUNCTION__, messageArray.count);
    return [messageArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    NSString* text = [(MessageModel*)[messageArray objectAtIndex:row] text];
    CGFloat textHeight = [NSString textHeight:text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(260,9999)];
    NSLog(@"%s, %lf", __FUNCTION__, textHeight);
    return textHeight + 60 + 60;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"TextCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    };
    UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:kTextLabel];
    UILabel* areaLabel = (UILabel*)[cell.contentView viewWithTag:kAreaLabel];
    UILabel* commentNumLabel = (UILabel*)[cell.contentView viewWithTag:kCommentLabel];
    UIImageView* commentImage = (UIImageView*)[cell.contentView viewWithTag:kCommentImage];
    
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    textLabel.text = currentMsg.text;
    areaLabel.text = currentMsg.area.area_name;
    commentNumLabel.text = [NSString stringWithFormat:@"%d", currentMsg.comments_count];
    
    int bgImageNo = currentMsg.background_no;
    if ( (1 == bgImageNo) || (2 == bgImageNo) )
    {
        [commentImage setImage:[UIImage imageNamed:@"comment_grey"]];
        [areaLabel setTextColor:UIColorFromRGB(0x969696)];
        [commentNumLabel setTextColor:UIColorFromRGB(0x969696)];
        [textLabel setTextColor:UIColorFromRGB(0x000000)];
        [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
    }
    else
    {
        [commentImage setImage:[UIImage imageNamed:@"comment_white"]];
        [areaLabel setTextColor:UIColorFromRGB(0x000000)];
        [commentNumLabel setTextColor:UIColorFromRGB(0x000000)];
        [textLabel setTextColor:UIColorFromRGB(0xffffff)];
        [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
    }
    if (3 == bgImageNo)
    {
        [commentNumLabel setTextColor:UIColorFromRGB(0xffffff)];
        [areaLabel setTextColor:UIColorFromRGB(0xffffff)];
    }
    return cell;
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
            if (_pullTableView.pullTableIsRefreshing == YES)
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
    PublishMsgViewController* publisMsgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishMsgVCIdentifier"];
    [self.navigationController pushViewController:publisMsgVC animated:YES];
}
@end

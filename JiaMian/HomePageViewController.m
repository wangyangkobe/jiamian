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
    
    //  int unreadCount = [[NetWorkConnect sharedInstance] notificationUnreadCount];
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [customButton addTarget:self action:@selector(unReadMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [customButton setImage:[UIImage imageNamed:@"ico-to-do-list"] forState:UIControlStateNormal];
    BBBadgeBarButtonItem *unReadMsgBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    unReadMsgBarButton.shouldHideBadgeAtZero = YES;
    //    unReadMsgBarButton.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];
    unReadMsgBarButton.badgeOriginX = 13;
    unReadMsgBarButton.badgeOriginY = -9;
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(settingBtnPressed:)];;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settingBarButton, unReadMsgBarButton, nil]];
    
    
    messageArray = [NSMutableArray array];
    [messageArray addObject:@"李克强总理近日主持召开国务院常务会议，确定进一步落实企业投资自主权的政策措施，决定在基础设施等领域推出一批鼓励社会资本参与的项目，部署促进市场公平竞争维护市场正常秩序工作。这些重大举措引起舆论广泛关注和热评。"];
    [messageArray addObject:@"the issue that's occurring is that the height of the label has empty space at its top and bottom, and that the longer the string inside it is, the larger that empty space is."];
    [messageArray addObject:@"Fuck You!"];
    [messageArray addObject:@"2006年的第一场雪，一群爱音乐的人在杭州的一家小咖啡屋开始了他们的追梦旅程。从一开始，他们就知道，这条路并不平坦，但是他们却为之血脉贲张。"];
    
    //    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
    //        NSArray* requestRes = [[NetWorkConnect sharedInstance] messageList:0 sinceId:0 maxId:INT_MAX count:20 trimArea:NO filterType:0];
    //        [messageArray addObjectsFromArray:requestRes];
    //
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            //  [self.pullTableView reloadData];
    //        });
    //    });
    
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
      [KxMenuItem menuItem:@"退出登录" image:nil target:self action:@selector(menuItemPressed:)],
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
    if ([menuItem.title isEqualToString:@"邀请朋友"]) {
        NSLog(@"邀请朋友");
    }else if([menuItem.title isEqualToString:@"意见反馈"]){
        
    }else if([menuItem.title isEqualToString:@"检查更新"]){
         [MobClick checkUpdate:@"New version" cancelButtonTitle:@"Skip" otherButtonTitles:@"Goto Store"];
    }else{
        BOOL result = [[NetWorkConnect sharedInstance] userLogOut];
        if (result) {
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
    return [messageArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    NSString* text = (NSString*)[messageArray objectAtIndex:row];
    CGFloat textHeight = [NSString textHeight:text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(240,9999)];
    NSLog(@"%s, %lf", __FUNCTION__, textHeight);
    return textHeight + 15 + 50;
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
    
    textLabel.text = (NSString*)[messageArray objectAtIndex:indexPath.row];
    areaLabel.text = @"华东理工";
    commentNumLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    msgDetailVC.msgText = (NSString*)[messageArray objectAtIndex:indexPath.row];
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
                                                                      maxId:0
                                                                      count:20
                                                                   trimArea:NO
                                                                 filterType:0];
        for (MessageModel* message in [newMessages reverseObjectEnumerator]){
            [messageArray insertObject:message atIndex:0];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (_pullTableView.pullTableIsRefreshing == YES) {
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            
            for(NSDictionary *result __unused in loadMoreRes){
                [indexPaths addObject:[NSIndexPath indexPathForRow:fromIndex inSection:0]];
                fromIndex++;
            }
            
            [_pullTableView beginUpdates];
            [_pullTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [_pullTableView endUpdates];
            // [_pullTableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            self.pullTableView.pullTableIsLoadingMore = NO;
        });
    });
}

- (IBAction)publishMessage:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    PublishMsgViewController* publisMsgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishMsgVCIdentifier"];
    [self.navigationController pushViewController:publisMsgVC animated:YES];
}
@end

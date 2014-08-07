//
//  UnReadMsgViewController.m
//  JiaMian
//
//  Created by wy on 14-4-28.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "UnReadMsgViewController.h"
#import "MessageDetailViewController.h"
#import "UILabel+Extensions.h"
#import "MessageModel.h"
#import "SVProgressHUD.h"

#define kNewPicView      7001
#define kTitleLabel      7002
#define kContentLabel    7003
#define KMsgBgImageView  7004
@interface UnReadMsgViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
}
@property (nonatomic, strong) NSMutableArray* notificationArr;
@end

@implementation UnReadMsgViewController

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.pullDelegate = self;
    self.tableView.tableHeaderView = nil;
    
    [self.tableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    _notificationArr = [NSMutableArray array];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:0 maxId:INT_MAX count:15];
        if (requestRes) {
            [_notificationArr addObjectsFromArray:requestRes];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
#pragma mark UITableView dataSource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_notificationArr count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175 + 10;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"UnReadMsgCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NotificationModel* notification = (NotificationModel*)[_notificationArr objectAtIndex:[indexPath row]];
    MessageModel* currentMsg = notification.message;
    UILabel* titleLabel       = (UILabel*)[cell.contentView viewWithTag:kTitleLabel];
    UILabel* contentLabel     = (UILabel*)[cell.contentView viewWithTag:kContentLabel];
    UIImageView* newImageView = (UIImageView*)[cell.contentView viewWithTag:kNewPicView];
    UIImageView* msgBgImageView = (UIImageView*)[cell.contentView viewWithTag:KMsgBgImageView];
    if (currentMsg.background_url && currentMsg.background_url.length > 0)
    {
        UIImage* maskImage = [UIImage imageNamed:@"blackalpha.png"];
        [contentLabel setBackgroundColor:[UIColor colorWithPatternImage:maskImage]];
        [msgBgImageView setImageWithURL:[NSURL URLWithString:currentMsg.background_url] placeholderImage:nil];
    }
    else
    {
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [msgBgImageView setImage:nil];
        int bgImageNo = currentMsg.background_no2;
        if (bgImageNo >=1 && bgImageNo <= 10)
        {
            [contentLabel setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
        }
        else
        {
            NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d.png", bgImageNo];
            UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
            [contentLabel setBackgroundColor:picColor];
        }
    }
    if (notification.status == 1)
    {
        [newImageView setImage:[UIImage imageNamed:@"new"]];
    }
    else
    {
        [newImageView setImage:nil];
    }
    [titleLabel setText:@"某某某回复了"];
    [titleLabel setTextColor:UIColorFromRGB(0x576b95)];
    [contentLabel setText:notification.message.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= _notificationArr.count)
        return;
    NotificationModel* notification = (NotificationModel*)[_notificationArr objectAtIndex:indexPath.row];
    MessageModel* message = notification.message;
    if (!message)
        return;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessageDetailViewController* messageDetailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    messageDetailVC.selectedMsg = message;
    [self.navigationController pushViewController:messageDetailVC animated:YES];

    notification.status = 2; //置为已读
    [_notificationArr replaceObjectAtIndex:indexPath.row withObject:notification];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.1f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:2.0f];
}

#pragma mark - Refresh and load more methods
- (void)refreshTable
{
    _tableView.pullTableIsRefreshing = NO;
}
- (void)loadMoreDataToTable
{
    if ([_notificationArr count] == 0)
    {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NotificationModel* lastNotification = [_notificationArr lastObject];
        NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] notificationShow:0
                                                                           maxId:lastNotification.notification_id
                                                                           count:15];
        __block NSInteger fromIndex = [_notificationArr count];
        [_notificationArr addObjectsFromArray:loadMoreRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.tableView.pullTableIsLoadingMore = NO;
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for(id result __unused in loadMoreRes)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:fromIndex inSection:0]];
                fromIndex++;
            }
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [_tableView endUpdates];
            if (indexPaths.count > 0)
                [self.tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    });
    
}
@end

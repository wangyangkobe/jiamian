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
#define kNewPicView      7001
#define kTitleLabel      7002
#define kContentLabel    7003
@interface UnReadMsgViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    NSMutableArray* unReadMsgArr;
}
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
    
    unReadMsgArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:0 maxId:INT_MAX count:15];
        [unReadMsgArr addObjectsFromArray:requestRes];
        
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
#pragma mark UITableView dataSource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [unReadMsgArr count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:[indexPath row]];
    //    CGFloat textHeight = [notification.message.text sizeWithFont:[UIFont systemFontOfSize:13]
    //                                               constrainedToSize:CGSizeMake(175, 48)
    //                                                   lineBreakMode:NSLineBreakByTruncatingTail].height;
    //    return textHeight + 10;
    return 48 + 10;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"UnReadMsgCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:[indexPath row]];
    UILabel* titleLabel = (UILabel*)[cell.contentView viewWithTag:kTitleLabel];
    UILabel* contentLabel = (UILabel*)[cell.contentView viewWithTag:kContentLabel];
    UIImageView* newImageView = (UIImageView*)[cell.contentView viewWithTag:kNewPicView];
    if (notification.status == 1) {
        [newImageView setImage:[UIImage imageNamed:@"new"]];
    }
    [titleLabel setText:@"有同学回复了"];
    [titleLabel setTextColor:UIColorFromRGB(0x576b95)];
    [contentLabel setText:notification.message.text];
    [contentLabel setTextColor:UIColorFromRGB(0x919191)];
    [contentLabel setBackgroundColor:UIColorFromRGB(0xefeeee)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= unReadMsgArr.count)
        return;
    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:indexPath.row];
    MessageModel* message = [[NetWorkConnect sharedInstance] messageShowByMsgId:notification.message.message_id];
    if (!message)
        return;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessageDetailViewController* messageDetailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    
    messageDetailVC.selectedMsg = message;
    [self.navigationController pushViewController:messageDetailVC animated:YES];
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:[indexPath row]];
//    if (1 == notification.status)
//    {
//        [cell.contentView setBackgroundColor:UIColorFromRGB(0xddffe5)];
//    }
//}
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NotificationModel* lastNotification = [unReadMsgArr lastObject];
        NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] notificationShow:0
                                                                           maxId:lastNotification.notification_id
                                                                           count:15];
        __block NSInteger fromIndex = [unReadMsgArr count];
        [unReadMsgArr addObjectsFromArray:loadMoreRes];
        
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
            
        });
    });
    
}
@end

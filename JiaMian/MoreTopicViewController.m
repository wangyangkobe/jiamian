//
//  MoreTopicViewController.m
//  JiaMian
//
//  Created by wanyang on 14-7-19.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "MoreTopicViewController.h"
#import "TopicModel.h"
#import "TopicDetailViewController.h"

#define kImageViewTag  3000
#define kTextLabelTag  3001
#define kNumLabelTag   3002
@interface MoreTopicViewController ()<UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate>
{
    NSMutableArray* topicArr;
}
@end

@implementation MoreTopicViewController

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
    // Do any additional setup after loading the view.topic
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pullDelegate = self;
    topicArr = [NSMutableArray array];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 50)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] topicList:0 maxId:INT_MAX count:10];
        [topicArr addObjectsFromArray:requestRes];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [_tableView reloadData];
        });
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [topicArr count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIndetifier = @"MoreTopicCell";
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIndetifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndetifier];
    }
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xf7f6f4)];
    
    TopicModel* topic = [topicArr objectAtIndex:indexPath.row];
    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:kImageViewTag];
    [imageView setImageWithURL:[NSURL URLWithString:topic.img_url] placeholderImage:nil];
    
    UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:kTextLabelTag];
    [textLabel setText:topic.topic_title];
    
    UILabel* numberLabel = (UILabel*)[cell.contentView viewWithTag:kNumLabelTag];
    [numberLabel setText:[NSString stringWithFormat:@"%d", topic.message_count]];
    [numberLabel setTextColor:UIColorFromRGB(0xfc5d20)];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    TopicModel* topic = (TopicModel*)[topicArr objectAtIndex:indexPath.row];
    TopicDetailViewController* topicDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TopicDetailVCIdentifier"];
    topicDetailVC.topic = topic;
    [self.navigationController pushViewController:topicDetailVC animated:YES];
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
    if (0 == [topicArr count])
        return;
    self.tableView.pullTableIsRefreshing = YES;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] topicList:0 maxId:INT_MAX count:10];
        if (requestRes)
        {
            topicArr = [NSMutableArray arrayWithArray:requestRes];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( _tableView.pullTableIsRefreshing )
            {
                _tableView.pullLastRefreshDate = [NSDate date];
                _tableView.pullTableIsRefreshing = NO;
                [_tableView reloadData];
            }
        });
    });
}

- (void)loadMoreDataToTable
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TopicModel* lastTopic = [topicArr lastObject];
        
        NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] topicList:0 maxId:lastTopic.topic_id count:10];
        __block NSInteger fromIndex = [topicArr count];
        [topicArr addObjectsFromArray:loadMoreRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
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
                [_tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            self.tableView.pullTableIsLoadingMore = NO;
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

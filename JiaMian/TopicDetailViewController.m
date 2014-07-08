//
//  TopicDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-7-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "MessageDetailViewController.h"

#define kTextLabel    8000
#define kAreaLabel    8001
#define kCommentLabel 8002
#define kCommentImage 8003
#define kLikeImage    8004
#define kLikeNumberLabel 8005
#define kVisibleImage 8006
#define kVisibleNumberLabel 8007
#define kBackgroundImageView 8008

@interface TopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    NSMutableArray* messageArray;
}

@end
static NSString* CellStr = @"TopicDetalCell";

@implementation TopicDetailViewController

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
    _pullTableView.delegate = self;
    _pullTableView.dataSource = self;
    _pullTableView.pullDelegate = self;
    messageArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] topicGetMessages:_topicId sinceId:0 maxId:INT_MAX count:15];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [messageArray addObjectsFromArray:res];
            [_pullTableView reloadData];
        });
    });
    self.title = _topicTitle;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    msgDetailVC.selectedMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:msgDetailVC animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellStr];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellStr];
    }
    MessageModel* currentMsg = (MessageModel*)[messageArray objectAtIndex:indexPath.row];
    UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:kTextLabel];
    UILabel* areaLabel          = (UILabel*)[cell.contentView viewWithTag:kAreaLabel];
    UILabel* likeNumerLabel     = (UILabel*)[cell.contentView viewWithTag:kLikeNumberLabel];
    UILabel* commentNumLabel    = (UILabel*)[cell.contentView viewWithTag:kCommentLabel];
    UILabel* visibleNumberLabel = (UILabel*)[cell.contentView viewWithTag:kVisibleNumberLabel];
    
    UIImageView* likeImage    = (UIImageView*)[cell.contentView viewWithTag:kLikeImage];
    
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
    
    UIImageView* bgImageView  = (UIImageView*)[cell.contentView viewWithTag:kBackgroundImageView];
    if (currentMsg.background_url && currentMsg.background_url.length > 0)
        [bgImageView setImage:[UIImage imageNamed:@"blackalpha"]];
    else
        [bgImageView setImage:nil];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL* imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?imageView/2/w/%d/h/%d/q/100",
                                                currentMsg.background_url, (int)SCREEN_WIDTH, (int)SCREEN_WIDTH]];
        [manager downloadWithURL:imageUrl
                         options:0
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image && finished)
                           {
                               [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:image]];
                           }
                       }];
    }
    else
    {
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
            [textLabel setTextColor:UIColorFromRGB(0xffffff)];
            if (9 == bgImageNo)
            {
                UIColor* picColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food"]];
                [cell.contentView setBackgroundColor:picColor];
            }
            else
            {
                [cell.contentView setBackgroundColor:UIColorFromRGB(COLOR_ARR[bgImageNo])];
            }
        }
    }
    if (currentMsg.has_like)
    {
        [likeImage setImage:[UIImage imageNamed:@"ic_liked"]];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

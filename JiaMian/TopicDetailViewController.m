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
#define kMaskImageView  8009
#define kMoreImageView 8010
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
    
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 50)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] topicGetMessages:_topic.topic_id sinceId:0 maxId:INT_MAX count:15];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [messageArray addObjectsFromArray:res];
            [SVProgressHUD dismiss];
            [_pullTableView reloadData];
            
            [self updateHeaderView];
        });
    });
    if ([_topic.topic_title length] > 8)
    {
        self.title = [NSString stringWithFormat:@"%@...", [_topic.topic_title substringToIndex:8]];
    }
    else
    {
        self.title = _topic.topic_title;
    }
}
-(void)updateHeaderView
{
    _msgLabel.text = _topic.topic_title;
    [_imageView setImageWithURL:[NSURL URLWithString:_topic.img_url] placeholderImage:nil];
    UIView* view = [_imageView superview];
    [view setBackgroundColor:UIColorFromRGB(0xf7f6f4)];
    if ([messageArray count] > 0)
    {
        MessageModel* message = [messageArray objectAtIndex:0];
        _timeLabel.text = [NSString stringWithFormat:@"最后更新%@", message.create_at];
    }
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
    UIImageView* moreImageV   = (UIImageView*)[cell.contentView viewWithTag:kMoreImageView];
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
    
    UITapGestureRecognizer* moreImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoreImageTapped:)];
    moreImageTap.numberOfTapsRequired = 1;
   // [moreImageTap setCancelsTouchesInView:YES];
    [moreImageV setUserInteractionEnabled:YES];
    [moreImageV addGestureRecognizer:moreImageTap];
    
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
- (void)handleMoreImageTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    UIImageView* tappedView = (UIImageView*)[gestureRecognizer view];
    UITableViewCell* tappedCell;
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        tappedCell = (UITableViewCell*)tappedView.superview.superview.superview;
    }else{
        tappedCell = (UITableViewCell*)tappedView.superview.superview;
    }
    
    UIView* moreView = [[UIView alloc] initWithFrame:CGRectMake(195, 180, 120, 100)];
    [moreView setBackgroundColor:[UIColor lightGrayColor]];
    UIButton* btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 120, 20)];
    [btn1.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn1 setTitle:@"分享" forState:UIControlStateNormal];
    UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 120, 20)];
    [btn2.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn2 setTitle:@"私信" forState:UIControlStateNormal];
    UIButton* btn3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 70, 120, 20)];
    [btn3.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn3 setTitle:@"举报或屏蔽" forState:UIControlStateNormal];
    [moreView addSubview:btn1];
    [moreView addSubview:btn2];
    [moreView addSubview:btn3];
    [tappedCell.contentView addSubview:moreView];
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
	   NSArray* result = [[NetWorkConnect sharedInstance] topicGetMessages:_topic.topic_id 
								    sinceId:sinceId 
								      maxId:INT_MAX 
								      count:15];     

        for (MessageModel* message in [result reverseObjectEnumerator]){
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
	NSArray* loadMoreRes = [[NetWorkConnect sharedInstance] topicGetMessages:_topic.topic_id 
									 sinceId:0 
									   maxId:lastMessage.message_id
									   count:15];
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

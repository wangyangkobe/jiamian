//
//  TopicDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-7-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "MessageDetailViewController.h"
#import "ChaViewController.h"
#import "MsgTableViewCell.h"

static NSString* msgCellIdentifier = @"MsgTableViewCellIdentifier";

@interface TopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    NSMutableArray* messageArray;
    UIView* moreBtnView;
    
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
    [self.pullTableView registerNib:[UINib nibWithNibName:@"MsgTableViewCell" bundle:nil] forCellReuseIdentifier:msgCellIdentifier];
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
    [cell.likeImageView setUserInteractionEnabled:YES];
    [cell.likeImageView addGestureRecognizer:likeImageTap];
    
    cell.selectionStyle = UITableViewCellAccessoryNone;
    
    return cell;
    
    //    UITapGestureRecognizer* moreImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoreImageTapped:)];
    //    moreImageTap.numberOfTapsRequired = 1;
    //    // [moreImageTap setCancelsTouchesInView:YES];
    //    [moreImageV setUserInteractionEnabled:YES];
    //    [moreImageV addGestureRecognizer:moreImageTap];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH;
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
    }
    
    [msgCell.commentImageView setImage:[UIImage imageNamed:@"comment_white"]];
    [msgCell.likeImageView setImage:[UIImage imageNamed:@"ic_like"]];
    if (currentMsg.has_like)
    {
        [msgCell.likeImageView setImage:[UIImage imageNamed:@"ic_liked"]];
    }
}
- (void)handleMoreImageTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    UITableViewCell* tappedCell = [UIView tableViewCellFromTapGestture:gestureRecognizer];
    NSIndexPath* tapIndexPath = [self.pullTableView indexPathForCell:tappedCell];
    NSArray* btnsConf =
    @[
      @{@"target": self, @"title": @"分享", @"selector": NSStringFromSelector(@selector(handleMoreAction:))},
      @{@"target": self, @"title": @"私信", @"selector": NSStringFromSelector(@selector(handleMoreAction:))},
      @{@"target": self, @"title": @"举报或屏蔽", @"selector": NSStringFromSelector(@selector(handleMoreAction:))}
      ];
    moreBtnView = [UIView configureMoreView:btnsConf];
    moreBtnView.tag = tapIndexPath.row;
    [tappedCell.contentView addSubview:moreBtnView];
}
- (void)handleMoreAction:(UIButton*)sender
{
    NSLog(@"%s", __FUNCTION__);
    NSInteger tapRow = sender.superview.tag;
    MessageModel* curMsg = (MessageModel*)[messageArray objectAtIndex:tapRow];
    [moreBtnView removeFromSuperview];
    NSString* btnTitle = sender.titleLabel.text;
    if ([btnTitle isEqualToString:@"分享"])
    {
        
    }
    else if ([btnTitle isEqualToString:@"私信"])
    {
        HxUserModel* hxUserInfo = [[NetWorkConnect sharedInstance] userGetByMsgId:curMsg.message_id];
        ChaViewController* chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishSiXinVCIndentifier"];
        
        chatVC.chatter = hxUserInfo.user.easemob_name;
        chatVC.myHeadImage = hxUserInfo.my_head_image;
        chatVC.chatterHeadImage = hxUserInfo.chat_head_image;
        chatVC.customFlag = curMsg.message_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    else
    {
        NSArray* btnsConf =
        @[
          @{@"target": self, @"title": @"分享", @"selector": NSStringFromSelector(@selector(handleMoreAction:))},
          @{@"target": self, @"title": @"私信", @"selector": NSStringFromSelector(@selector(handleMoreAction:))},
          @{@"target": self, @"title": @"举报或屏蔽", @"selector": NSStringFromSelector(@selector(handleMoreAction:))}
          ];
        UIView* juBaoView = [UIView configureJuBaoView:btnsConf];
        UITableViewCell* cell = [self.pullTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tapRow inSection:0]];
        [cell.contentView addSubview:juBaoView];
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

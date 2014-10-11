//
//  HuiFuViewController.m
//  JiaMian
//
//  Created by wanyang on 14-9-14.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "HuiFuViewController.h"
#import "HuiFuCollectionCell.h"
#import "MessageModel.h"
#import "MJRefresh.h"

@interface HuiFuViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
        NSInteger nextPage;
    NSMutableArray* huiFuArr;
    NSMutableArray* messageArray;
}
@property (retain, nonatomic) UIView* hintView;
@end
static NSString* kCollectionViewCellIdentifier = @"HuiFuCell";
@implementation HuiFuViewController

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
    self.collectionView.backgroundColor = UIColorFromRGB(0x344c62);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical=YES;
    huiFuArr = [NSMutableArray array];

    UINib* nib = [UINib nibWithNibName:NSStringFromClass([HuiFuCollectionCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    // self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addHeader];
    [self addFooter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView*)hintView {
    if (_hintView == nil) {
        _hintView = [[UIView alloc] initWithFrame:self.view.bounds];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        [label setText:@"暂未收到私信，试着向他人发起私信吧!"];
        label.center = _hintView.center;
        [_hintView addSubview:label];
    }
    return _hintView;
}
#pragma mark UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 6.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 6.0f;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(151.0f, 151.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return huiFuArr.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.collectionView.backgroundColor=UIColorFromRGB(0x344c62);
    HuiFuCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                          forIndexPath:indexPath];
    NotificationModel* notification = [huiFuArr objectAtIndex:indexPath.row];
    MessageModel* message = notification.message;
    
    //提醒label
    cell.warningLabel.layer.cornerRadius = 10;
    cell.warningLabel.backgroundColor=UIColorFromRGB(0xf54646);
    if (notification.unread_count != 0)
    {
        [cell.warningLabel setHidden:NO];
        [cell.warningLabel setText:[NSString stringWithFormat:@"%d", notification.unread_count]];
    }
    else
    {
        [cell.warningLabel setHidden:YES];
    }
    if (message.background_url && message.background_url.length > 0)
    {
        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:notification.message.background_url]];
    }
    else
    {
        [cell.bgImageView setImage:nil];
        int bgImageNo = message.background_no2;
        
        NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d@2x.jpg", bgImageNo];
        [cell.bgImageView setImage:[UIImage imageNamed:imageName]];
    }
    [cell.textLabel setText:notification.message.text];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationModel* notification = [huiFuArr objectAtIndex:indexPath.row];
    MessageModel* message = [[NetWorkConnect sharedInstance] messageShowByMsgId:notification.message.message_id];
    if (!message)
        return;
    MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    msgDetailVC.selectedMsg = message;
    msgDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgDetailVC animated:YES];
    
    
    notification.status = 2; //置为已读
    notification.unread_count = 0;
    [huiFuArr replaceObjectAtIndex:indexPath.row withObject:notification];
    //  [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self.collectionView reloadData];
}
- (void)addHeader
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加下拉刷新头部控件
    [self.collectionView addHeaderWithCallback:^{
        // 进入刷新状态就会回调这个Block
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:0 maxId:INT_MAX count:15];
            if (requestRes) {
                [huiFuArr removeAllObjects];
                [huiFuArr addObjectsFromArray:requestRes];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [SVProgressHUD dismiss];
                if (requestRes.count == 0) {
                    [vc.collectionView headerEndRefreshing];

                    [self.collectionView addSubview:self.hintView];
                } else
                {
                    [self.collectionView reloadData];
                    [vc.collectionView headerEndRefreshing];
                }
            });
        });
    }];
    
    // 自动刷新(一进入程序就下拉刷新)
    [self.collectionView headerBeginRefreshing];
}
- (void)addFooter
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加上拉刷新尾部控件
    [vc.collectionView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            nextPage+=[huiFuArr count];
            NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:nextPage maxId:INT_MAX count:15];
            if (requestRes) {
                [huiFuArr addObjectsFromArray:requestRes];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [SVProgressHUD dismiss];
                if (requestRes.count == 0) {
                    [self.collectionView addSubview:self.hintView];
                    [vc.collectionView footerEndRefreshing];

                } else
                {
                    [self.collectionView reloadData];
                    [vc.collectionView footerEndRefreshing];
                    
                }
            });
        });
    }];
}
@end

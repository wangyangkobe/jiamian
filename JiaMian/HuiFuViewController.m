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


@interface HuiFuViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray* huiFuArr;
    NSMutableArray* messageArray;
}

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
    // UIView *blueView = [[UIView alloc]init];
    // blueView.backgroundColor = UIColorFromRGB(0xf6f5f1);
    // self.collectionView.backgroundView = blueView;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    huiFuArr = [NSMutableArray array];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"刷新中..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:0 maxId:INT_MAX count:15];
        if (requestRes) {
            [huiFuArr addObjectsFromArray:requestRes];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.collectionView reloadData];
        });
    });
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([HuiFuCollectionCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.0f, 15.0f, 10.0f, 15.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140.0f, 140.0f);
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
    NSLog(@"%s, %d", __FUNCTION__, huiFuArr.count);
    NSLog(@"%@", huiFuArr);
    return huiFuArr.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.collectionView.backgroundColor=UIColorFromRGB(0x344c62);
    NSLog(@"%s", __FUNCTION__);
    HuiFuCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    NotificationModel* notification = [huiFuArr objectAtIndex:indexPath.row];
    MessageModel* message = notification.message;
    
    //提醒label
    cell.warningLabel.layer.cornerRadius = 10;
    cell.warningLabel.backgroundColor=UIColorFromRGB(0xf54646);
    if (notification.unread_count != 0)
    {
        [cell.warningLabel setText:[NSString stringWithFormat:@"%d", notification.unread_count]];
    }
    if (message.background_url && message.background_url.length > 0)
    {
        [cell.bgImageView setImageWithURL:[NSURL URLWithString:notification.message.background_url] placeholderImage:nil];
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
    MessageDetailViewController* msgDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailVCIdentifier"];
    msgDetailVC.selectedMsg = notification.message;
    [self.navigationController pushViewController:msgDetailVC animated:YES];
}
@end

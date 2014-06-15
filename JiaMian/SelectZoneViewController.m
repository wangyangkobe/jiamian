//
//  SelectZoneViewController.m
//  JiaMian
//
//  Created by wy on 14-6-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "SelectZoneViewController.h"
#import "CustomCollectionCell.h"
#import "HomePageViewController.h"
#import "SVProgressHUD.h"
static NSString* kCollectionViewCellIdentifier = @"Cell";
@interface SelectZoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableSet* selectedIndexSet;
    NSMutableArray* zoneArray;
    NSMutableSet* selectZoneIDs;
    NSArray* lastSelectZones;
}

@end

@implementation SelectZoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    lastSelectZones = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    NSLog(@"last select = %@", [lastSelectZones description]);
    selectedIndexSet = [NSMutableSet set];
    selectZoneIDs = [NSMutableSet set];
    
    if ((self.isFirstSelect == NO) && lastSelectZones)
    {
        [selectZoneIDs addObjectsFromArray:lastSelectZones];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([CustomCollectionCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    CGRect statusBarFrame  = [[UIApplication sharedApplication] statusBarFrame]; //height = 20
    //创建UINavigationBar
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + statusBarFrame.size.height)];
        [self.collectionView setContentInset:UIEdgeInsetsMake(statusBarFrame.size.height, 0, 0, 0)];
    } else {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    navigationBar.delegate = self;
    //创建UINavigationItem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择关注的圈子"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(handleDone:)];
    navigationItem.rightBarButtonItem = rightBtnItem;
    
    zoneArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20];
        [zoneArray addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [zoneArray count];
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* zone = (AreaModel*)[zoneArray objectAtIndex:indexPath.row];
    CustomCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz"];
    cell.zoneName.text = zone.area_name;
    cell.likeNumber.text = [NSString stringWithFormat:@"%d", zone.hots];
    if ([selectZoneIDs  containsObject:[NSString stringWithFormat:@"%d", zone.area_id]])
    {
        cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    }
    
    if ( (_firstSelect == NO) && [lastSelectZones containsObject:[NSString stringWithFormat:@"%d", zone.area_id]])
    {
        cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    }
    
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* selectZone = (AreaModel*)[zoneArray objectAtIndex:indexPath.row];
    NSLog(@"%s", __FUNCTION__);
    CustomCollectionCell* selectedCell = (CustomCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([selectedIndexSet containsObject:indexPath])
    {
        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz"];
        [selectedIndexSet removeObject:indexPath];
        [selectZoneIDs removeObject:[NSString stringWithFormat:@"%d", selectZone.area_id]];
    }
    else
    {
        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
        [selectedIndexSet addObject:indexPath];
        [selectZoneIDs addObject:[NSString stringWithFormat:@"%d", selectZone.area_id]];
    }
    
    if ([selectZoneIDs containsObject:[NSString stringWithFormat:@"%d", selectZone.area_id]])
    {
        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    }
}
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView* footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionFooter" forIndexPath:indexPath];
        return footerView;
    }
    return nil;
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
    return CGSizeMake(140.0f, 80.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 40);
}
- (IBAction)loadMoreBtnPress:(id)sender
{
    NSLog(@"load more");
    if ([zoneArray count] == 0)
        return;
    
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"获取中..."];
    
    [self performSelector:@selector(loadMoreBtnPressHelp) withObject:nil afterDelay:0.5];
}
- (void)loadMoreBtnPressHelp
{
    NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:40];
    [zoneArray removeAllObjects];
    [zoneArray addObjectsFromArray:result];
    [SVProgressHUD dismiss];
    [self.collectionView reloadData];
}
- (void)handleDone:(id)sender
{
    if ([selectedIndexSet count] > 5)
    {
        AlertContent(@"同学，您最多只能选择5个圈子");
        return;
    }
    if ([selectZoneIDs count] != 0)
    {
        NSString* res = [[selectZoneIDs allObjects] componentsJoinedByString:@","];
        UserModel* user = [[NetWorkConnect sharedInstance] userChangeZone:res];
        if (user == nil)
            return;
        NSLog(@"sle == %@", [selectZoneIDs description]);
        [[NSUserDefaults standardUserDefaults] setObject:selectZoneIDs forKey:kSelectZones];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    if (self.isFirstSelect)
    {
        HomePageViewController* homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    //   [[NSNotificationCenter defaultCenter] postNotificationName:@"publishMessageSuccess" object:self userInfo:nil];
}
@end

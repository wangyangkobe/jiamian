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
#import "ZoneDetailViewController.h"

static NSString* kCollectionViewCellIdentifier = @"Cell";

@interface SelectZoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZoneDetailVCDelegate>
{
    int selectScopeId;
    NSMutableArray* selectZones;
    NSMutableDictionary* configureDict;
}
@property (nonatomic, retain) UISearchDisplayController* searchController;
@property (retain, nonatomic) UISearchBar *searchBar;

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
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *blueView = [[UIView alloc]init];
    blueView.backgroundColor = UIColorFromRGB(0xf6f5f1);
    self.collectionView.backgroundView = blueView;
 
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
    }
    else
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    navigationBar.delegate = self;
    //创建UINavigationItem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择你的圈子"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    //    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    //                                                                                  target:self
    //                                                                                  action:@selector(handleDone:)];
    //    navigationItem.rightBarButtonItem = rightBtnItem;
    
    NSData* lastSelectData = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    NSArray* lastSelectZones = [NSKeyedUnarchiver unarchiveObjectWithData:lastSelectData];
    NSLog(@"lastSelectZones = %@", lastSelectZones);
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:kCongigureDict];
    if (lastSelectZones && data && !self.isFirstSelect)
    {
        configureDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"configure dict = %@", configureDict);
        
        for (AreaModel* zone in lastSelectZones)
        {
            if (zone.type == ZoneTypeCompany)
            {
                NSDictionary* currentConf = [configureDict objectForKey:[NSNumber numberWithInt:0]];
                [currentConf setValue:zone.area_name forKey:@"name"];
                [currentConf setValue:[NSNumber numberWithInt:0x048bcd] forKey:@"color"];
            }
            else if (zone.type == ZoneTypeIndustry)
            {
                NSDictionary* currentConf = [configureDict objectForKey:[NSNumber numberWithInt:2]];
                [currentConf setValue:zone.area_name forKey:@"name"];
                [currentConf setValue:[NSNumber numberWithInt:0xffd800] forKey:@"color"];
            }
            else
            {
                NSDictionary* currentConf = [configureDict objectForKey:[NSNumber numberWithInt:1]];
                [currentConf setValue:zone.area_name forKey:@"name"];
                [currentConf setValue:[NSNumber numberWithInt:0xf7925c] forKey:@"color"];
            }
        }
    }
    else  //第一次登录
    {
        NSMutableDictionary* scope1 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+公司", @0xadd5e6, [NSNull null], nil]
                                                                         forKeys:@[@"id", @"name", @"color", @"zone"] ];
        NSMutableDictionary* scope2 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+学校", @0xf6d7c4, [NSNull null], nil]
                                                                         forKeys:@[@"id", @"name", @"color", @"zone"] ];
        NSMutableDictionary* scope3 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+行业", @0xf9eca8, [NSNull null], nil]
                                                                         forKeys:@[@"id", @"name", @"color", @"zone"] ];
        
        configureDict = [NSMutableDictionary dictionaryWithObjects:@[scope1, scope2, scope3]
                                                           forKeys:@[@0, @1, @2] ];
    }
    
    data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //  selectZones = [NSMutableArray arrayWithArray:@[ [NSNull null], [NSNull null], [NSNull null] ]];
    if (lastSelectZones)
    {
        selectZones = [NSMutableArray arrayWithArray:[self filterArray:lastSelectZones]];
    }
    else
    {
        selectZones = [NSMutableArray array];
    }
}
- (NSArray*)filterArray:(NSArray*)array
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    for(AreaModel* zone in array)
    {
        [dict setObject:zone forKey:[NSNumber numberWithInteger:zone.type]];
    }
    return [dict allValues];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ZoneDetailVCDelegate
- (void)zoneDetailViewController:(ZoneDetailViewController *)viewController didFinishSelectZone:(AreaModel *)zone
{
    NSLog(@"%@", selectZones);
    NSDictionary* currentConf = [configureDict objectForKey:[NSNumber numberWithInt:selectScopeId]];
    [currentConf setValue:zone.area_name forKey:@"name"];
    if (0 == selectScopeId){
        [currentConf setValue:[NSNumber numberWithInt:0x048bcd] forKey:@"color"];
    }else if (1 == selectScopeId){
        [currentConf setValue:[NSNumber numberWithInt:0xf7925c] forKey:@"color"];
    }else{
        [currentConf setValue:[NSNumber numberWithInt:0xf9eca8] forKey:@"color"];
    }
    
    if ([selectZones containsObject:zone] == NO)
    {
        [selectZones addObject:zone];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray* indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectScopeId inSection:0]];
    [_collectionView reloadItemsAtIndexPaths:indexPaths];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    int row = indexPath.row;
    if (row < 3)
    {
        NSDictionary* configure = [configureDict objectForKey:[NSNumber numberWithInt:row]];
        [cell.zoneName setText:[configure objectForKey:@"name"]];
        int colorValue = [[configure objectForKey:@"color"] integerValue];
        [cell setBackgroundColor:UIColorFromRGB(colorValue)];
    }
    else
    {
        [cell setDashedBorder:YES];
        UIImageView* addIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        addIV.center = cell.contentView.center;
        [cell.contentView addSubview:addIV];
        [addIV setImage:[UIImage imageNamed:@"ic_add"]];
        [cell setBackgroundColor:UIColorFromRGB(0xf6f5f1)];
    }
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 3)
    {
        selectScopeId = indexPath.row;
        ZoneDetailViewController* zoneDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoneDetailVCIdentifier"];
        zoneDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if (selectScopeId == 0) {
            zoneDetailVC.zoneType = ZoneTypeCompany;
        }else if(selectScopeId == 1){
            zoneDetailVC.zoneType = ZoneTypeSchool;
        }else{
            zoneDetailVC.zoneType = ZoneTypeIndustry;
        }
        zoneDetailVC.delegate = self;
        [self presentViewController:zoneDetailVC animated:YES completion:nil];
    }
    else
    {
        AlertContent(@"此版本暂不支持解锁更多圈子");
    }
}
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView* footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionFooter" forIndexPath:indexPath];
        
        for (UIView* view in footerView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton* btn = (UIButton*)view;
                [btn setBackgroundColor:UIColorFromRGB(0x3094fa)];
                if (_firstSelect == NO)
                {
                    [btn setTitle:@"确定" forState:UIControlStateNormal];
                }
            }
        }
        return footerView;
    }
    //    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    //    {
    //        UICollectionReusableView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionHeader" forIndexPath:indexPath];
    //        return headerView;
    //    }
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
    return CGSizeMake(140.0f, 140.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 40);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(SCREEN_WIDTH, 40);
//}
- (IBAction)nextStepBtnPress:(id)sender
{
    selectZones = [NSMutableArray arrayWithArray:[self filterArray:selectZones]];
    if([selectZones count] == 0)
    {
        AlertContent(@"同学，您最少要选择一个圈子吧");
        return;
    }
    if ([selectZones count] != 0)
    {
        NSMutableArray* zoneIdArr = [NSMutableArray array];
        for (AreaModel* area in selectZones)
        {
            if ([area isEqual:[NSNull null]] == NO)
            {
                [zoneIdArr addObject:[NSString stringWithFormat:@"%d", area.area_id]];
            }
        }
        NSString* res = [zoneIdArr componentsJoinedByString:@","];
        UserModel* user = [[NetWorkConnect sharedInstance] userChangeZone:res];
        if (user == nil)
            return;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:selectZones];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSelectZones];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeAreaSuccess" object:self userInfo:nil];
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
    
}

- (void)handleDone:(id)sender
{
    //    if([selectZoneIds count] == 0)
    //    {
    //        AlertContent(@"同学，您最少要选择一个圈子吧");
    //        return;
    //    }
    //    if ([selectZoneIds count] != 0)
    //    {
    //        NSString* res = [selectZoneIds componentsJoinedByString:@","];
    //        UserModel* user = [[NetWorkConnect sharedInstance] userChangeZone:res];
    //        if (user == nil)
    //            return;
    //        [[NSUserDefaults standardUserDefaults] setObject:selectZoneIds forKey:kSelectZones];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //    }
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeAreaSuccess" object:self userInfo:nil];
    //    if (self.isFirstSelect)
    //    {
    //        HomePageViewController* homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
    //        [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
    //    }
    //    else
    //    {
    //        [self dismissViewControllerAnimated:YES completion:^{
    //        }];
    //    }
}
@end

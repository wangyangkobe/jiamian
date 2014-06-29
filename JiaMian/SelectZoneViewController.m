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
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(handleDone:)];
    navigationItem.rightBarButtonItem = rightBtnItem;
    
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:kCongigureDict];
    configureDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"configure = %@", configureDict);
    if (_firstSelect || configureDict == nil)
    {
        NSMutableDictionary* scope1 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+公司", @0xadd5e6, nil]
                                                                         forKeys:@[@"id", @"name", @"color"] ];
        NSMutableDictionary* scope2 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+学校", @0xf6d7c4, nil]
                                                                         forKeys:@[@"id", @"name", @"color"] ];
        NSMutableDictionary* scope3 = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@1, @"+行业", @0xf9eca8, nil]
                                                                         forKeys:@[@"id", @"name", @"color"] ];
        
        configureDict = [NSMutableDictionary dictionaryWithObjects:@[scope1, scope2, scope3]
                                                           forKeys:@[@0, @1, @2] ];
    }
    
    NSData* zoneData = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    NSArray* lastSelectZones = [NSKeyedUnarchiver unarchiveObjectWithData:zoneData];
    selectZones = [NSMutableArray array];
    if (lastSelectZones && _firstSelect)
    {
        int stop = MIN(3, lastSelectZones.count);
        for (int i = 0; i < stop; i++)
        {
            [selectZones addObject:lastSelectZones[i]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ZoneDetailVCDelegate
- (void)zoneDetailViewController:(ZoneDetailViewController *)viewController didFinishSelectZone:(AreaModel *)zone
{
    NSDictionary* currentConf = [configureDict objectForKey:[NSNumber numberWithInt:selectScopeId]];
    [currentConf setValue:zone.area_name forKey:@"name"];
    if (0 == selectScopeId){
        [currentConf setValue:[NSNumber numberWithInt:0x048bcd] forKey:@"color"];
    }else if (1 == selectScopeId){
        [currentConf setValue:[NSNumber numberWithInt:0xf7925c] forKey:@"color"];
    }else{
        [currentConf setValue:[NSNumber numberWithInt:0xf9eca8] forKey:@"color"];
    }
    if ([selectZones containsObject:selectZones] == NO)
    {
        [selectZones setObject:zone atIndexedSubscript:selectScopeId];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
    //return [zonesArr count];
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
    
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    
    selectScopeId = indexPath.row;
    ZoneDetailViewController* zoneDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoneDetailVCIdentifier"];
    zoneDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    zoneDetailVC.delegate = self;
    [self presentViewController:zoneDetailVC animated:YES completion:nil];
    
}
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView* footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionFooter" forIndexPath:indexPath];
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
    NSLog(@"%s", __FUNCTION__);
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
            [zoneIdArr addObject:[NSString stringWithFormat:@"%d", area.area_id]];
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

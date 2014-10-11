//
//  SelectZoneViewController.m
//  JiaMian
//
//  Created by wy on 14-6-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "SelectZoneViewController.h"
#import "CustomCollectionCell.h"
#import "MessageListViewController.h"
#import "SVProgressHUD.h"
#import "ZoneDetailViewController.h"

static NSString* kCollectionViewCellIdentifier = @"Cell";

@interface SelectZoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZoneDetailVCDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSInteger selectScopeId;
    NSMutableDictionary* configureDict;
}
@property (nonatomic, retain) UISearchDisplayController* searchController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (nonatomic,retain ) UIImageView *companyImView;
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
    //两个label
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 52)];
    label.text=@"看看你的同事，同学匿名后都聊什么";
    label.textColor = UIColorFromRGB(0x666666);
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:19];
    //label.numberOfLines=2;

    
    UILabel* tiXingLb=[[UILabel alloc]initWithFrame:CGRectMake(0, 320, 320, 50)];
    tiXingLb.text=@"长按可取消关注圈子";
    tiXingLb.font = [UIFont systemFontOfSize:12];
    tiXingLb.textColor=UIColorFromRGB(0xadb0b2);
    tiXingLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tiXingLb];
    
    //图片
    self.companyImView=[[UIImageView alloc]initWithFrame:CGRectMake(55, 75, 40, 40)];
    [_companyImView setImage:[UIImage imageNamed:@"company.png"]];
    [self.view addSubview:_companyImView];
    
    UIImageView* schoolImView=[[UIImageView alloc]initWithFrame:CGRectMake(55, 170, 40, 40)];
    [schoolImView setImage:[UIImage imageNamed:@"school.png"]];
    
    [self.view addSubview:schoolImView];
    
    
    UIImageView* industryImView=[[UIImageView alloc]initWithFrame:CGRectMake(55, 257, 40, 40)];
    [industryImView setImage:[UIImage imageNamed:@"business.png"]];
    [self.view addSubview:industryImView];
    
    
    // Do any additional setup after loading the view.
    UIView *blueView = [[UIView alloc]init];
    blueView.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundView = blueView;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.8; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    
    [self.collectionView addGestureRecognizer:lpgr];
    
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([CustomCollectionCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    if (_firstSelect)
    {
        [self configureNavigationBar];
    }
    else
    {
        CGRect oldFrame = _collectionView.frame;
        [_collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, oldFrame.size.height + 44 + 20)];
        self.title = @"选择你的圈子";
    }
    
    NSData* lastSelectData = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    NSArray* lastSelectZones;
    if (lastSelectData == nil) {
        lastSelectZones = [NSArray array];
    }else{
        lastSelectZones = [NSKeyedUnarchiver unarchiveObjectWithData:lastSelectData];
    }
    NSLog(@"%s, lastSelectZones = %@", __FUNCTION__, lastSelectZones);
    
    NSMutableDictionary* company = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@0, @"+公司", @0x5cbbea, [NSNull null], nil]
                                                                      forKeys:@[@"zoneId", @"name", @"color", @"zone"] ];
    NSMutableDictionary* school = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@0, @"+学校", @0xe7a079, [NSNull null], nil]
                                                                     forKeys:@[@"zoneId", @"name", @"color", @"zone"] ];
    NSMutableDictionary* industry = [NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:@0, @"+行业", @0xe1cd5c, [NSNull null], nil]
                                                                       forKeys:@[@"zoneId", @"name", @"color", @"zone"] ];
    
    configureDict = [NSMutableDictionary dictionaryWithObjects:@[company, school, industry]
                                                       forKeys:@[[NSNumber numberWithInt:ZoneTypeCompany],
                                                                 [NSNumber numberWithInt:ZoneTypeSchool],
                                                                 [NSNumber numberWithInt:ZoneTypeIndustry] ] ];

    for (AreaModel* zone in lastSelectZones)
    {
        NSMutableDictionary* zoneConf = [configureDict objectForKey:[NSNumber numberWithInt:zone.type]];
        [zoneConf setValue:zone.area_name forKey:@"name"];
        [zoneConf setValue:[NSNumber numberWithInt:zone.area_id] forKey:@"zoneId"];
        [zoneConf setValue:zone forKey:@"zone"];
        if (zone.type == ZoneTypeCompany) {
            [zoneConf setValue:[NSNumber numberWithInt:0x048bcd] forKey:@"color"];
        } else if(zone.type == ZoneTypeSchool) {
            [zoneConf setValue:[NSNumber numberWithInt:0xf68e55] forKey:@"color"];
        } else if(zone.type == ZoneTypeIndustry) {
            [zoneConf setValue:[NSNumber numberWithInt:0xe5c828] forKey:@"color"];
        }
    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)configureNavigationBar
{
    CGRect statusBarFrame  = [[UIApplication sharedApplication] statusBarFrame]; //height = 20
    //创建UINavigationBar
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + statusBarFrame.size.height)];
        [self.collectionView setContentInset:UIEdgeInsetsMake(statusBarFrame.size.height, 0, 0, 0)];
        [navigationBar setBarTintColor:UIColorFromRGB(0x242730)];
        [navigationBar setTranslucent:NO];
    }
    else
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [navigationBar setTintColor:UIColorFromRGB(0x242730)];
    }
    [navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                            NSForegroundColorAttributeName, nil]];
    navigationBar.delegate = self;
    //创建UINavigationItem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择你的圈子"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self nextStepBtnPress:nil];
    }
    [super viewWillDisappear:animated];
}
- (ZoneType)mapCellIdToZoneType:(NSInteger)scopeId
{
    if (0 == scopeId) {
        return ZoneTypeCompany;
    } else if (1 == scopeId) {
        return ZoneTypeSchool;
    } else {
        return ZoneTypeIndustry;
    }
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateEnded == gestureRecognizer.state)
    {
        NSLog(@"%s", __FUNCTION__);
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath == nil || indexPath.row == 3)
        {
            NSLog(@"couldn't find index path");
        }
        else
        {
            //UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            NSMutableDictionary* zoneConf = [configureDict objectForKey:
                                             [NSNumber numberWithInt:[self mapCellIdToZoneType:indexPath.row]]];
            NSInteger zoneId = [[zoneConf objectForKey:@"zoneId"] integerValue];
            if (zoneId == 0)
                return;
            
            int number = 0;
            for (NSNumber* key in configureDict) {
                NSDictionary* zoneConf = [configureDict objectForKey:key];
                NSInteger zoneId = [[zoneConf objectForKey:@"zoneId"] integerValue];
                if (zoneId != 0) {
                    number++;
                }
            }
            if (number == 1)
            {
                AlertContent(@"同学，您不能取消最后一个圈子!");
                return;
            }
            
            [UIAlertView showWithTitle:@"提示"
                               message:@"确定取消关注该圈子?"
                     cancelButtonTitle:@"取消"
                     otherButtonTitles:@[@"确定"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 0)
                                      return;
                                  
                                  [zoneConf setValue:[NSNumber numberWithInteger:0] forKey:@"zoneId"];
                                  [zoneConf setObject:[NSNull null] forKey:@"zone"];
                                  if (0 == indexPath.row)
                                  {
                                      [zoneConf setValue:@"+公司" forKey:@"name"];
                                      [zoneConf setValue:@0xadd5e6 forKey:@"color"];
                                  }
                                  else if (1 == indexPath.row)
                                  {
                                      [zoneConf setValue:@"+学校" forKey:@"name"];
                                      [zoneConf setValue:@0xf6d7c4 forKey:@"color"];
                                  }
                                  else if (2 == indexPath.row)
                                  {
                                      [zoneConf setValue:@"+行业" forKey:@"name"];
                                      [zoneConf setValue:@0xf9eca8 forKey:@"color"];
                                  }
                                  
                                  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
                                  [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  NSArray* indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [_collectionView reloadItemsAtIndexPaths:indexPaths];
                                  });
                              }];
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
    NSLog(@"zoneId = %d", zone.area_id);
    NSDictionary* currentConf = [configureDict objectForKey:
                                 [NSNumber numberWithInt:[self mapCellIdToZoneType:selectScopeId]]];
    
    [currentConf setValue:zone.area_name forKey:@"name"];
    [currentConf setValue:[NSNumber numberWithInteger:zone.area_id] forKey:@"zoneId"];
    [currentConf setValue:zone forKey:@"zone"];
    
    if (0 == selectScopeId) {
        [currentConf setValue:[NSNumber numberWithInt:0x048bcd] forKey:@"color"];
    } else if (1 == selectScopeId) {
        [currentConf setValue:[NSNumber numberWithInt:0xf7925c] forKey:@"color"];
    } else {
        [currentConf setValue:[NSNumber numberWithInt:0xffd800] forKey:@"color"];
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
    return 3;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (row < 3)
    {
        NSDictionary* configure = [configureDict objectForKey:[NSNumber numberWithInt:[self mapCellIdToZoneType:row]]];
        [cell.zoneName setText:[configure objectForKey:@"name"]];
        NSInteger colorValue = [[configure objectForKey:@"color"] integerValue];
        [cell setBackgroundColor:UIColorFromRGB(colorValue)];
    }
    else
    {
        [cell setDashedBorder:YES];
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
        zoneDetailVC.zoneType = [self mapCellIdToZoneType:indexPath.row];
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
        //        for (UIView* view in footerView.subviews)
        //        {
        //            if ([view isKindOfClass:[UIButton class]])
        //            {
        //                UIButton* btn = (UIButton*)view;
        //                [btn setBackgroundColor:UIColorFromRGB(0x3094fa)];
        //                btn.showsTouchWhenHighlighted = YES;
        //                if (_firstSelect == NO)
        //                {
        //                    [btn setTitle:@"确定" forState:UIControlStateNormal];
        //                }
        //            }
        //        }
        return footerView;
    }
    if ( (_firstSelect == NO) && [kind isEqualToString:UICollectionElementKindSectionHeader] )
    {
        UICollectionReusableView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionHeader" forIndexPath:indexPath];
        return headerView;
    }
    return nil;
}
#pragma mark UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 37.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12.0f;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12.0f, 12.0f, 12.0f, 12.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(245.0f, 81.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (_firstSelect) {
        return CGSizeMake(SCREEN_WIDTH, 40);
    }
    return CGSizeMake(0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (_firstSelect) {
        return CGSizeMake(0, 0);
    }
    return CGSizeMake(SCREEN_WIDTH, 40);
}
- (IBAction)nextStepBtnPress:(id)sender
{
    NSMutableArray* zoneIdArr = [NSMutableArray array];
    for (NSNumber* key in configureDict)
    {
        NSDictionary* zoneConf = [configureDict objectForKey:key];
        NSInteger zoneId = [[zoneConf objectForKey:@"zoneId"] integerValue];
        if (zoneId != 0) {
            [zoneIdArr addObject:[NSString stringWithFormat:@"%ld", (long)zoneId]];
        }
    }
    if ([zoneIdArr count] == 0) {
        AlertContent(@"您最少要选择一个圈子吧");
        return;
    }
    
    NSString* zoneIdStr = [zoneIdArr componentsJoinedByString:@","];
    NSLog(@"zoneIdStr = %@", zoneIdStr);
    UserModel* user = [[NetWorkConnect sharedInstance] userChangeZone:zoneIdStr];
    if (user == nil)
        return;
    
    NSLog(@"area = %@", user.areas);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user.areas];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSelectZones];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:configureDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCongigureDict];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeAreaSuccess" object:self userInfo:nil];
    
    if (self.isFirstSelect)
    {
        BannerViewController* bannerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarVCIdentifier"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:bannerVC];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}
@end

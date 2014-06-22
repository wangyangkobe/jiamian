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
@interface SelectZoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource,UITableViewDelegate>
{
    NSMutableSet* selectedIndexSet;
    NSMutableArray* zonesArr;
    NSMutableSet* selectZoneIdSet;
    NSArray* lastSelectZones;
    
    NSMutableArray* fastSearchRes;
    BOOL isShowSearchRes;
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
    lastSelectZones = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    NSLog(@"last select = %@", [lastSelectZones description]);
    selectedIndexSet = [NSMutableSet set];
    selectZoneIdSet = [NSMutableSet set];
    
    if ((self.isFirstSelect == NO) && lastSelectZones)
    {
        [selectZoneIdSet addObjectsFromArray:lastSelectZones];
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
        [self.collectionView setContentInset:UIEdgeInsetsMake(statusBarFrame.size.height + 44, 0, 0, 0)];
    } else {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [self.collectionView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
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
    
    zonesArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20 FilterType:0 keyWord:nil];
        [zonesArr addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
    
    fastSearchRes = [NSMutableArray array];
    
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 44 + statusBarFrame.size.height, 320, 44)];
    }
    else
    {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 44, 320, 44)];
    }
    _searchBar.delegate = self;
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDelegate= self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.view addSubview:_searchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [zonesArr count];
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* zone = (AreaModel*)[zonesArr objectAtIndex:indexPath.row];
    CustomCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz"];
    cell.zoneName.text = zone.area_name;
    cell.likeNumber.text = [NSString stringWithFormat:@"%d", zone.hots];
    if ([selectZoneIdSet  containsObject:[NSString stringWithFormat:@"%d", zone.area_id]])
    {
        cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    }
    
    //    if ( (_firstSelect == NO) && [lastSelectZones containsObject:[NSString stringWithFormat:@"%d", zone.area_id]])
    //    {
    //        cell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    //    }
    
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* selectZone = (AreaModel*)[zonesArr objectAtIndex:indexPath.row];
    NSLog(@"%s", __FUNCTION__);
    CustomCollectionCell* selectedCell = (CustomCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([selectZoneIdSet containsObject:[NSString stringWithFormat:@"%d", selectZone.area_id]] == NO)
    {
        if ([selectZoneIdSet count] >= 5)
        {
            AlertContent(@"同学，您最多只能选择5个圈子");
            return;
        }
        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
        [selectedIndexSet addObject:indexPath];
        [selectZoneIdSet addObject:[NSString stringWithFormat:@"%d", selectZone.area_id]];
    }
    else
    {
        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz"];
        [selectedIndexSet removeObject:indexPath];
        [selectZoneIdSet removeObject:[NSString stringWithFormat:@"%d", selectZone.area_id]];
    }
    //    if ([selectZoneIdSet containsObject:[NSString stringWithFormat:@"%d", selectZone.area_id]])
    //    {
    //        selectedCell.selectedImageV.image = [UIImage imageNamed:@"ic_qz_marked"];
    //    }
}
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView* footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionFooter" forIndexPath:indexPath];
        
        if (isShowSearchRes)
        {
            UIButton* btn = (UIButton*)[footerView viewWithTag:9999];
            [btn setTitle:@"显示全部" forState:UIControlStateNormal];
        }
        return footerView;
    }
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind      withReuseIdentifier:@"CollectionHeader" forIndexPath:indexPath];
        return headerView;
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
    return UIEdgeInsetsMake(0.0f, 15.0f, 10.0f, 15.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140.0f, 80.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 40);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 40);
}
- (IBAction)loadMoreBtnPress:(id)sender
{
    NSLog(@"load more");
    if (isShowSearchRes)
    {
        [zonesArr removeAllObjects];
        isShowSearchRes = NO;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20 FilterType:0 keyWord:nil];
            [zonesArr addObjectsFromArray:result];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
    }
    else
    {
        if ([zonesArr count] == 0)
            return;
        
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
        [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
        [SVProgressHUD showWithStatus:@"获取中..."];
        
        [self performSelector:@selector(loadMoreBtnPressHelp) withObject:nil afterDelay:0.5];
    }
}
- (void)loadMoreBtnPressHelp
{
    AreaModel* zone = (AreaModel*)[zonesArr lastObject];
    NSArray* result = [[NetWorkConnect sharedInstance] areaList:zone.sequence maxId:INT_MAX count:20 FilterType:0 keyWord:nil];
    [zonesArr addObjectsFromArray:result];
    [SVProgressHUD dismiss];
    [self.collectionView reloadData];
}
- (void)handleDone:(id)sender
{
    if ([selectZoneIdSet count] > 5)
    {
        AlertContent(@"同学，您最多只能选择5个圈子");
        return;
    }
    if([selectZoneIdSet count] == 0)
    {
        AlertContent(@"同学，您最少要选择一个圈子吧");
        return;
    }
    if ([selectZoneIdSet count] != 0)
    {
        NSString* res = [[selectZoneIdSet allObjects] componentsJoinedByString:@","];
        UserModel* user = [[NetWorkConnect sharedInstance] userChangeZone:res];
        if (user == nil)
            return;
        [[NSUserDefaults standardUserDefaults] setObject:[selectZoneIdSet allObjects] forKey:kSelectZones];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s", __FUNCTION__);
    return [fastSearchRes count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* zone = (AreaModel*)[fastSearchRes objectAtIndex:indexPath.row];
    
    static NSString* CellIdentifier = @"TableViewCell";
    UITableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = zone.area_name;
    return cell;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%s, searchText = %@", __FUNCTION__, searchText);
    if([searchText length] == 0)
        return;
    [fastSearchRes removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:100 FilterType:1 keyWord:searchText];
        [fastSearchRes addObjectsFromArray:res];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* searchText = [searchBar text];
    if([searchText length] == 0)
        return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:100 FilterType:2 keyWord:searchText];
        [zonesArr removeAllObjects];
        [zonesArr addObjectsFromArray:res];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController setActive:NO];
            isShowSearchRes = YES;
            [self.collectionView reloadData];
        });
    });
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AreaModel* zone = (AreaModel*)[fastSearchRes objectAtIndex:indexPath.row];
    [_searchBar setText:zone.area_name];
    [fastSearchRes removeAllObjects];
    [fastSearchRes addObject:zone];
    [self.searchDisplayController.searchResultsTableView reloadData];
}
@end

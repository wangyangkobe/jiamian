//
//  ZoneDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-6-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ZoneDetailViewController.h"

#define kZoneNameLabelTag 9000
@interface ZoneDetailViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray* zonesArr;
    NSMutableArray* searchRes;
}
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@end

@implementation ZoneDetailViewController

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
    [self configureNavigationBar];
    [self configureTableHeaderView:1];
    [self configureTableFooterView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    zonesArr = [NSMutableArray array];
    searchRes = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20 FilterType:0 keyWord:nil];
        [zonesArr addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        CGRect frame = self.searchBar.frame;
        [self.searchBar setFrame:CGRectMake(frame.origin.x, frame.origin.y + 20, frame.size.width, frame.size.height)];
    }
    else
    {
        //   [_searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        return [searchRes count];
    }
    else
    {
        return [zonesArr count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"ZoneCellIdentifier";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    int row = indexPath.row;
    AreaModel* zone = nil;
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        zone = (AreaModel*)[searchRes objectAtIndex:row];
    }
    else
    {
        zone = (AreaModel*)[zonesArr objectAtIndex:row];
    }
    UILabel* zoneNameLabel = (UILabel*)[cell viewWithTag:kZoneNameLabelTag];
    [zoneNameLabel setText:zone.area_name];
    
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* currCell = [tableView cellForRowAtIndexPath:indexPath];
    int new = [indexPath row];
    int old = (_lastIndexPath != nil) ? [_lastIndexPath row] : -1;
    
    if(new != old)
    {
        currCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:_lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        _lastIndexPath = indexPath;
    }
    
    AreaModel* zone = nil;
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        zone = (AreaModel*)[searchRes objectAtIndex:indexPath.row];
    }
    else
    {
        zone = (AreaModel*)[zonesArr objectAtIndex:indexPath.row];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate zoneDetailViewController:self didFinishSelectZone:zone];
    }];
}
- (void)selectAreaDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchDispalyController delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%s, searchText = %@", __FUNCTION__, searchText);
    if([searchText length] == 0)
        return;
    [searchRes removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:100 FilterType:1 keyWord:searchText];
        [searchRes addObjectsFromArray:res];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchDispalyController.searchResultsTableView reloadData];
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
        [searchRes removeAllObjects];
        [searchRes addObjectsFromArray:res];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchDispalyController.searchResultsTableView reloadData];
        });
    });
}
- (void)configureNavigationBar
{
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + StatusBarHeight)];
        [self.tableView setContentInset:UIEdgeInsetsMake(StatusBarHeight, 0, 0, 0)];
    }
    else
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择你的圈子"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
}
- (void)configureTableHeaderView:(int)scopeId
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setText:@"目前支持全国几十万家公司，以下是热门公司"];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label sizeToFit];
    label.center = headerView.center;
    [headerView addSubview:label];
    [_tableView setTableHeaderView:headerView];
}
- (void)configureTableFooterView
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(60, 5, 200, 40)];
    [btn setTitle:@"加载更多" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loadMoreZones:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor blueColor]];
    [footerView addSubview:btn];
    [_tableView setTableFooterView:footerView];
    _tableView.tableFooterView.userInteractionEnabled = YES;
}
- (void)loadMoreZones:(id)sender
{
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"获取中..."];
    
    [self performSelector:@selector(loadMoreBtnPressHelp) withObject:nil afterDelay:0.5];
}
- (void)loadMoreBtnPressHelp
{
    AreaModel* zone = (AreaModel*)[zonesArr lastObject];
    NSArray* result = [[NetWorkConnect sharedInstance] areaList:zone.sequence maxId:INT_MAX count:20 FilterType:0 keyWord:nil];
    [zonesArr addObjectsFromArray:result];
    [SVProgressHUD dismiss];
    [_tableView reloadData];
}
@end
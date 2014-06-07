//
//  SelectAreaViewController.m
//  JiaMian
//
//  Created by wy on 14-5-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "SelectAreaViewController.h"
#import "AreaModel.h"
#include "HomePageViewController.h"

@interface SelectAreaViewController ()
{
    NSMutableArray* areaArray;
    NSInteger selcetedAreaId;
}

@end

@implementation SelectAreaViewController

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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    areaArray = [NSMutableArray array];
    self.lastSelectedIndex = 0;
    
    CGRect statusBarFrame  = [[UIApplication sharedApplication] statusBarFrame]; //height = 20
    
    //创建UINavigationBar
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + statusBarFrame.size.height)];
        [self.tableView setContentInset:UIEdgeInsetsMake(statusBarFrame.size.height, 0, 0, 0)];
    } else {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    navigationBar.delegate = self;
    //创建UINavigationItem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择学校"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(selectAreaDone:)];
    if (self.isFirstSelect)
    {
        navigationItem.rightBarButtonItem = rightBtnItem;
    }else
    {
        UINavigationItem* backBtnItem = [[UINavigationItem alloc] initWithTitle:@"假面校园"];
        NSArray* items = [[NSArray alloc] initWithObjects:backBtnItem, navigationItem, nil];
        [navigationBar setItems:items animated:NO];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20];
        [areaArray addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}
- (void)selectAreaDone:(id)sender
{
    if (selcetedAreaId > 0)
    {
        UserModel* user = [[NetWorkConnect sharedInstance] userChangeArea:selcetedAreaId];
        if (user == nil)
            return;
        [[NSUserDefaults standardUserDefaults] setInteger:selcetedAreaId forKey:kUserAreaId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    HomePageViewController* homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"publishMessageSuccess" object:self userInfo:nil];
    [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    //在此处添加点击back按钮之后的操作代码
    [self selectAreaDone:item];
    return TRUE;
}
#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [areaArray count];
}

#pragma mark - UITableView Delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AreaModel* area = (AreaModel*)[areaArray objectAtIndex:indexPath.row];
    static NSString* areaCellIdentifier = @"AreaCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:areaCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:areaCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = area.area_name;
    NSInteger userAreaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
    if (userAreaId == indexPath.row + 1)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.lastSelectedIndex = indexPath.row;
        selcetedAreaId = userAreaId;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell* lastSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastSelectedIndex
                                                                                            inSection:0]];
    lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    self.lastSelectedIndex = indexPath.row;
    
    UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    AreaModel* currentArea = (AreaModel*)[areaArray objectAtIndex:indexPath.row];
    selcetedAreaId = currentArea.area_id;
    
    [[NSUserDefaults standardUserDefaults] setInteger:selcetedAreaId forKey:kUserAreaId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

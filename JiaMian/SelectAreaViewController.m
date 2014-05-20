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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    areaArray = [NSMutableArray array];
    self.lastSelectedIndex = 0;
    
    //创建navbar
    UINavigationBar* navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    //创建navbaritem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"假面-匿名校园"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(selectAreaDone:)];
    if (self.isFirstSelect) {
        navigationItem.rightBarButtonItem = rightBtnItem;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:20];
        [areaArray addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}
- (void)selectAreaDone:(id)sender {
    if (selcetedAreaId > 0) {
        HomePageViewController* homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
    } else {
        AlertContent(@"同学，你还没选择社区呢");
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:areaCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = area.area_name;
    NSInteger userAreaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
    if (userAreaId == indexPath.row + 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.lastSelectedIndex = indexPath.row;
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
    
    if (!self.isFirstSelect) {
        [self performSelector:@selector(selectAreaDone:) withObject:nil afterDelay:0.5];
    }
}
@end

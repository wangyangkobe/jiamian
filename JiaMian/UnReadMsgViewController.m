//
//  UnReadMsgViewController.m
//  JiaMian
//
//  Created by wy on 14-4-28.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "UnReadMsgViewController.h"

#define kHeadPicView     7001
#define kTitleLabel      7002
#define kContentLabel    7003
@interface UnReadMsgViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* unReadMsgArr;
}
@end

@implementation UnReadMsgViewController

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
    unReadMsgArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* requestRes = [[NetWorkConnect sharedInstance] notificationShow:0 maxId:INT_MAX count:30];
        [unReadMsgArr addObjectsFromArray:requestRes];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView dataSource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [unReadMsgArr count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:[indexPath row]];
    CGFloat textHeight = [NSString textHeight:notification.message.text
                                 sizeWithFont:[UIFont systemFontOfSize:17]
                            constrainedToSize:CGSizeMake(240, 9999)];
    return textHeight;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"UnReadMsgCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NotificationModel* notification = (NotificationModel*)[unReadMsgArr objectAtIndex:[indexPath row]];
    UILabel* contentLabel = (UILabel*)[cell.contentView viewWithTag:kContentLabel];
    [contentLabel setText:notification.message.text];
    return cell;
}
@end

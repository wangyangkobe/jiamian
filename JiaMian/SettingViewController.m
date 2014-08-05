//
//  SettingViewController.m
//  JiaMian
//
//  Created by wanyang on 14-7-19.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "SettingViewController.h"
#import "LogInViewController.h"
#import "UMFeedback.h"
#import "AboutViewController.h"
@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingViewController

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
    self.title = @"设置";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(80, 75, 160, 40)];
    [button setBackgroundColor:UIColorFromRGB(0xff6f6f)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"注销登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    button.showsTouchWhenHighlighted = YES;
    [footerView addSubview:button];
    
    _tableView.tableFooterView = footerView;
}
- (void)logOut:(id)sender
{
    BOOL result = [[NetWorkConnect sharedInstance] userLogOut];
    if (result)
    {
        [APService setTags:[NSSet setWithObjects:@"offline", nil]
                     alias:@""
          callbackSelector:nil
                    target:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserLogIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        LogInViewController* logInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:logInVC];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 2;
    } else {
        return 4;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return @"提醒设置";
    } else {
        return @"其他设置";
    }
}

- (void)switchChangeAction:(id)sender {
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    UISwitch *switchBtn = (UISwitch*)sender;
    if (5000 == switchBtn.tag) {
        [userDef setObject:[NSString bool2str:switchBtn.isOn] forKey:kAlertShake];
    } else {
        [userDef setObject:[NSString bool2str:switchBtn.isOn] forKey:kAlertSound];
    }
    [userDef synchronize];
    BOOL shakeAlert = [NSString str2bool:[userDef stringForKey:kAlertShake]];
    BOOL soundAlert = [NSString str2bool:[userDef stringForKey:kAlertSound]];
    if (shakeAlert && soundAlert) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|
                                                                               UIRemoteNotificationTypeSound|
                                                                               UIRemoteNotificationTypeAlert)];
    } else if (shakeAlert) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert)];
    } else if (soundAlert) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifer;
    if (0 == indexPath.section) {
        cellIdentifer = @"SettingCell1";
    } else {
        cellIdentifer = @"SettingCell2";
    }
    UITableViewCell* cell = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    if (indexPath.section == 0) {
        UISwitch* switchBtn;
        if (IOS_NEWER_OR_EQUAL_TO_7) {
            switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 5, 50, 50)];
        } else {
            switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(215, 8, 45, 50)];
        }
        [switchBtn addTarget:self action:@selector(switchChangeAction:) forControlEvents:UIControlEventValueChanged];
        NSString* switchKey;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"震动";
            switchBtn.tag = 5000;
            switchKey = kAlertShake;
        } else {
            cell.textLabel.text = @"声音";
            switchBtn.tag = 5001;
            switchKey = kAlertSound;
        }
        NSString* storedValue =  [[NSUserDefaults standardUserDefaults] stringForKey:switchKey];
        if (storedValue == nil) {
            [switchBtn setOn:YES];
        } else if ([storedValue isEqualToString:@"NO"]) {
            [switchBtn setOn:NO];
        } else {
            [switchBtn setOn:YES];
        }
        [cell.contentView addSubview:switchBtn];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"邀请朋友";
                break;
            case 1:
                cell.textLabel.text = @"选择圈子";
                break;
            case 2:
                cell.textLabel.text = @"意见反馈";
                break;
            case 3:
                cell.textLabel.text = @"关于";
                break;
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
        return;
    
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (0 == row)
    {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMengAppKey
                                          shareText:@"亲，来玩玩假面吧!下载链接:http://www.jiamiantech.com"
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline, nil]
                                           delegate:nil];
        
    }
    else if(1 == row)
    {
        SelectZoneViewController* selectZoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectZoneVCIdentifier"];
        selectZoneVC.firstSelect = NO;
        // [self presentViewController:selectZoneVC animated:YES completion:nil];
        [self.navigationController pushViewController:selectZoneVC animated:YES];
    }
    else if(2 == row)
    {
        [UMFeedback showFeedback:self withAppkey:kUMengAppKey];
    }
    else
    {
        AboutViewController* aboutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutVCIdentifier"];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

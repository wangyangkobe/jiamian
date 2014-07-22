//
//  LogInViewController.m
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "LogInViewController.h"
#import "HomePageViewController.h"
#import "SelectAreaViewController.h"
#import "RegisterViewController.h"
#import "ShowInfoViewController.h"
@interface LogInViewController () <TencentSessionDelegate>

@property (nonatomic, retain) TencentOAuth *tencentOAuth;
@property (nonatomic, retain) NSArray* permissions;
@end

@implementation LogInViewController

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
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentQQAppKey andDelegate:self];
    //_tencentOAuth.redirectURI = kTencentQQRedirectURI;
    _permissions = [NSArray arrayWithObjects:@"get_user_info", @"add_t", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    
    if ([TencentOAuth iphoneQQInstalled] == NO)
    {
        self.sinaBtn.frame = self.qqBtn.frame;
        self.qqBtn.hidden = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}

- (IBAction)sinaWBLogIn:(id)sender
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kSinaRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"LogInViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (IBAction)tencentQQLogIn:(id)sender
{
    [_tencentOAuth authorize:_permissions];
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}
- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && (0 != [_tencentOAuth.accessToken length]))
    {
        // 记录登录用户的OpenID、Token以及过期时间
        NSLog(@"accessToken = %@, openId = %@, expireDate = %@", _tencentOAuth.accessToken,
              _tencentOAuth.openId,
              _tencentOAuth.expirationDate);
        
        UserModel* userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:_tencentOAuth.accessToken
                                                                         userType:UserTypeQQ
                                                                     userIdentity:nil];
        if (userSelf) //login successful
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] setObject:_tencentOAuth.accessToken forKey:kLogInToken];
            [[NSUserDefaults standardUserDefaults] setInteger:UserTypeQQ forKey:kLogInType];
            [[NSUserDefaults standardUserDefaults] synchronize];
           
            NSMutableSet *tags = [NSMutableSet set];
            [tags addObject:@"online"];
            for(AreaModel* area in userSelf.areas)
                [tags addObject:[NSString stringWithFormat:@"%d", area.area_id]];
            [APService setTags:tags
                         alias:[NSString stringWithFormat:@"%ld", userSelf.user_id]
              callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                        target:nil];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            if (userSelf.area == nil)
            {
                SelectZoneViewController* selectZoneVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SelectZoneVCIdentifier"];
                selectZoneVC.firstSelect = YES;
                [[UIApplication sharedApplication].keyWindow setRootViewController:selectZoneVC];
            }
            else
            {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userSelf.areas];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSelectZones];
                
                [[NSUserDefaults standardUserDefaults] setInteger:userSelf.area.area_id forKey:kUserAreaId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                HomePageViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
                [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
            }
        }
    }
    else
    {
        NSLog(@"Tencent QQ登录不成功, 没有获取accesstoken.");
    }
}
- (IBAction)logInWithUserName:(id)sender
{
    RegisterViewController* registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterVCIdentifier"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:registerVC];
}
- (void)tencentDidNotLogin:(BOOL)cancelled
{
}
-( void)tencentDidNotNetWork
{
}

- (IBAction)showUserInfo:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ShowInfoViewController* showInfoVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShowInfoVCIdentifier"];
    [self presentViewController:showInfoVC animated:YES completion:nil];
}
@end

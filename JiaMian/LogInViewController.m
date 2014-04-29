//
//  LogInViewController.m
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "LogInViewController.h"

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


- (IBAction)sinaWBLogIn:(id)sender {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kSinaRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"LogInViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (IBAction)tencentQQLogIn:(id)sender {
    [_tencentOAuth authorize:_permissions inSafari:NO];
}

- (void)tencentDidLogin{
    if (_tencentOAuth.accessToken && (0 != [_tencentOAuth.accessToken length])) {
        // 记录登录用户的OpenID、Token以及过期时间
        NSLog(@"accessToken = %@, openId = %@, expireDate = %@", _tencentOAuth.accessToken,
              _tencentOAuth.openId,
              _tencentOAuth.expirationDate);
        
        UserModel* userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:_tencentOAuth.accessToken userType:UserTypeQQ];
        if (userSelf) //login successful
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
            UITabBarController* mainTableVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TabBarVCIdentifier"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:mainTableVC];
        }
    } else {
        NSLog(@"Tencent QQ登录不成功, 没有获取accesstoken.");
    }
}
-(void)tencentDidNotLogin:(BOOL)cancelled{
}
-(void)tencentDidNotNetWork{
}
@end

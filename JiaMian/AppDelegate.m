//
//  AppDelegate.m
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"
#import "HomePageViewController.h"
#import "SelectAreaViewController.h"
#import "UMSocialQQHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"%s", __FUNCTION__);
    [self clearDefaults];
    
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x242730)];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    else{
        [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0x242730)];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    BOOL isLogIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserLogIn];
    if ( NO == isLogIn )
    {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LogInViewController* logInVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
        [self.window setRootViewController:logInVC];
    }
    else
    {
        NSInteger logInType = [[NSUserDefaults standardUserDefaults] integerForKey:kLogInType];
        if (UserTypeRegister == logInType)
        {
            NSString* passWord = [[NSUserDefaults standardUserDefaults] stringForKey:kLogInToken];
            NSString* userName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
            [[NetWorkConnect sharedInstance] userLogInWithToken:[NSString md5HexDigest:passWord]
                                                       userType:(int)logInType
                                                   userIdentity:userName];
        }
        else
        {
            NSString* token = [[NSUserDefaults standardUserDefaults] stringForKey:kLogInToken];
            [[NetWorkConnect sharedInstance] userLogInWithToken:token userType:(int)logInType userIdentity:nil];
        }
    }
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kSinaAppKey];
    
    [MobClick setAppVersion:XcodeAppVersion];
    [UMSocialData setAppKey:kUMengAppKey];
    [UMSocialConfig setSupportSinaSSO:YES appRedirectUrl:@"https://api.weibo.com/oauth2/default.html"];
    
    [MobClick checkUpdate];
    
    [MobClick startWithAppkey:kUMengAppKey reportPolicy:SEND_INTERVAL channelId:nil];
    [MobClick updateOnlineConfig];  //在线参数配置
    
    [UMSocialWechatHandler setWXAppId:kWeChatAppId url:@"http://www.umeng.com/social"];
    //qq和qq空间分享
    [UMSocialQQHandler setQQWithAppId:kTencentQQAppKey appKey:kTencentQQKey url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setSupportQzoneSSO:YES];
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                   | UIRemoteNotificationTypeAlert |
                                                   UIRemoteNotificationTypeSound)];
    // Required
    [APService setupWithOption:launchOptions];
    
    //注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
	NSString *apnsCertName = @"jiamian_dev";
	[[EaseMob sharedInstance] registerSDKWithAppKey:kHuanXinAppKey apnsCertName:apnsCertName];
	[[EaseMob sharedInstance] enableBackgroundReceiveMessage];
	[[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sourceApplication isEqualToString:@"com.sina.weibo"])
        return [WeiboSDK handleOpenURL:url delegate:self];
    else if( [sourceApplication isEqualToString:@"com.tencent.xin"] )
        return [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    else  //com.tencent.mqq (qq和qq空间分享)
        return [TencentOAuth HandleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ( [TencentOAuth CanHandleOpenURL:url] )
        return [TencentOAuth HandleOpenURL:url];
    else if([url.description hasPrefix:@"wechat"] || [url.description hasPrefix:@"qqshare"] )
        return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    else
        return YES;
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString* wbToken = [(WBAuthorizeResponse *)response accessToken];
        NSString* userId = [(WBAuthorizeResponse*)response userID];
        NSLog(@"wbToken = %@, weiboUserId = %@", wbToken, userId);
        
        UserModel* userSelf;
        if ( (wbToken!= nil) && (userId != nil) )
            userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:wbToken userType:UserTypeWeiBo userIdentity:nil];
        
        if (userSelf) //login successful
        {
            NSLog(@"user sina log in successful!, userId = %ld", userSelf.user_id);
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userSelf.easemob_name
                                                                password:userSelf.easemob_pwd
                                                              completion:^(NSDictionary *loginInfo, EMError *error) {
                                                                  if (error) {
                                                                      NSLog(@"环信-登录失败");
                                                                  }else {
                                                                      NSLog(@"环信-登录成功");
                                                                  }
                                                              } onQueue:nil];
            
            NSMutableSet *tags = [NSMutableSet set];
            [tags addObject:@"online"];
            for(AreaModel* area in userSelf.areas)
                [tags addObject:[NSString stringWithFormat:@"%d", area.area_id]];
            [APService setTags:tags
                         alias:[NSString stringWithFormat:@"%ld", userSelf.user_id]
              callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                        target:self];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES       forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] setObject:wbToken forKey:kLogInToken];
            [[NSUserDefaults standardUserDefaults] setInteger:UserTypeWeiBo forKey:kLogInType];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            if (userSelf.area == nil)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSelectZones];
                [[NSUserDefaults standardUserDefaults] synchronize];
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
                [self.window setRootViewController:homeVC];
            }
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%s, token = %@", __FUNCTION__, deviceToken.description);
    [APService registerDeviceToken:deviceToken];
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%s, %@", __FUNCTION__, userInfo);
    // If the application state was inactive, this means the user pressed an action button
    // from a notification.
    if (application.applicationState == UIApplicationStateInactive)
    {
        [self analyseRemoteNotification:userInfo];
    }
    [APService handleRemoteNotification:userInfo];
}
-(void)analyseRemoteNotification:(NSDictionary*)userInfo
{
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString* alert = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    NSString* sound = [aps valueForKey:@"sound"]; //播放的声音
    
    NSInteger msgId = [[userInfo valueForKey:@"message_id"] integerValue];
    NSLog(@"alert =[%@], badge=[%ld], sound=[%@], msgId =[%ld]", alert, (long)badge, sound, (long)msgId);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showRomoteNotification" object:nil userInfo:userInfo];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillResignActive:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillEnterForeground:application];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [UMSocialSnsService applicationDidBecomeActive];
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationDidBecomeActive:application];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"%s", __FUNCTION__);
    if (application.applicationState == UIApplicationStateInactive)
    {
        [self analyseRemoteNotification:userInfo];
    }
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
#endif


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // 让SDK得到App目前的各种状态，以便让SDK做出对应当前场景的操作
	[[EaseMob sharedInstance] applicationWillTerminate:application];
}

- (void)clearDefaults
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	if ([defs boolForKey:@"donotclearme1.5.3"] == NO)
	{
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[defs removePersistentDomainForName:appDomain];
		[defs setBool:YES forKey:@"donotclearme1.5.3"];
	}
    [defs synchronize];
}

@end

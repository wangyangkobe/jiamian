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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    BOOL isLogIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserLogIn];
    if ( NO == isLogIn )
    {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LogInViewController* logInVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
        [self.window setRootViewController:logInVC];
    }
    else
    {
        NSString* token     = [[NSUserDefaults standardUserDefaults] stringForKey:kLogInToken];
        NSInteger logInType = [[NSUserDefaults standardUserDefaults] integerForKey:kLogInType];
        [[NetWorkConnect sharedInstance] userLogInWithToken:token
                                                   userType:logInType
                                                      error:nil];
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
    
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    
    return YES;
}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"url = %@, sourceApplication = %@", url, sourceApplication);
    
    if ([sourceApplication isEqualToString:@"com.sina.weibo"])
        return [WeiboSDK handleOpenURL:url delegate:self];
    else if( [sourceApplication isEqualToString:@"com.tencent.xin"] )
        return [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    else  //com.tencent.mqq
        return [TencentOAuth HandleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"%s, url = %@", __FUNCTION__, url);
    
    if ( [TencentOAuth CanHandleOpenURL:url] )
        return [TencentOAuth HandleOpenURL:url];
    else if([ url.description hasPrefix:@"wechat" ])
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
        NSLog(@"wbToken = %@, userID = %@", wbToken, userId);
        
        NSError* error;
        UserModel* userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:wbToken
                                                                         userType:UserTypeWeiBo
                                                                            error:&error];
        if (userSelf) //login successful
        {
            NSLog(@"user sina log in successful!");
            
            [APService setTags:[NSSet setWithObjects:@"online", @"1", nil]
                         alias:[NSString stringWithFormat:@"%ld", userSelf.user_id]
              callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                        target:self];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES       forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] setObject:wbToken forKey:kLogInToken];
            [[NSUserDefaults standardUserDefaults] setInteger:UserTypeWeiBo forKey:kLogInType];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            HomePageViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
            [self.window setRootViewController:homeVC];
        }
        else
        {
            //AlertContent([error.userInfo valueForKey:@"err_msg"]);
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%s, token = %@", __FUNCTION__, deviceToken.description);
    [APService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"===============%@", userInfo);
    [APService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
#endif


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

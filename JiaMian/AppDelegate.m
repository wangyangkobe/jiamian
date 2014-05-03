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
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kSinaAppKey];
    
    [MobClick setAppVersion:XcodeAppVersion];
    [UMSocialData setAppKey:kUMengAppKey];
    //[MobClick checkUpdate];
    [MobClick startWithAppkey:kUMengAppKey reportPolicy:SEND_INTERVAL channelId:nil];
    [MobClick updateOnlineConfig];  //在线参数配置
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"url = %@, sourceApplication = %@", url, sourceApplication);
    
    if ([sourceApplication isEqualToString:@"com.sina.weibo"])
        return [WeiboSDK handleOpenURL:url delegate:self];
    else  //com.tencent.mqq
        return [TencentOAuth HandleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ( [TencentOAuth CanHandleOpenURL:url] )
        return [TencentOAuth HandleOpenURL:url];
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
        NSString* userID = [(WBAuthorizeResponse*)response userID];
        NSLog(@"wbToken = %@, userID = %@", wbToken, userID);
        
        NSError* error;
        UserModel* userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:wbToken
                                                                     userIdentify:userID
                                                                         userType:UserTypeWeiBo
                                                                            error:&error];
        if (userSelf) //login successful
        {
            NSLog(@"user sina log in successful!");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserLogIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            HomePageViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
            [self.window setRootViewController:homeVC];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

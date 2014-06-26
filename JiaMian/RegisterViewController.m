//
//  RegisterViewController.m
//  JiaMian
//
//  Created by wy on 14-6-4.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "RegisterViewController.h"
#import "LogInViewController.h"
#import "SelectAreaViewController.h"
#import "HomePageViewController.h"
#import "SVProgressHUD.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        [self.scrollView setContentOffset:CGPointMake(0, -20)];
    }
    
    // [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, 1.1 * SCREEN_HEIGHT)];
    UITapGestureRecognizer* tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:tapViewGesture];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkQQInstalled];
    [TencentOAuth iphoneQQInstalled];
}
- (void)dismissKeyBoard:(UIGestureRecognizer*)gesture
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnBtnPress:(id)sender
{
    LogInViewController* logInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:logInVC];
}

- (IBAction)forgetPassWord:(id)sender
{
    AlertContent(@"请联系admin@jiamiantech.com");
}

- (IBAction)registerBtnPress:(UIButton*)sender
{
    BOOL checkRes = [self validateUserNameAndPassWord];
    if (checkRes)
    {
        [sender setTag:6998]; //注册
        [SVProgressHUD showWithStatus:@"正在注册..."];
        [self performSelector:@selector(handleBtnAction:) withObject:sender afterDelay:0.5];
    }
}

- (IBAction)logInBtnPress:(UIButton*)sender
{
    BOOL checkRes = [self validateUserNameAndPassWord];
    if (checkRes)
    {
        [sender setTag:6999];
        [SVProgressHUD showWithStatus:@"正在登录..."];
        [self performSelector:@selector(handleBtnAction:) withObject:sender afterDelay:0.5];
    }
}
- (BOOL)validateUserNameAndPassWord
{
    NSString* userName = _userName.text;
    NSString* passWord = _passWord.text;
    if (userName == nil || passWord == nil)
    {
        AlertContent(@"用户名或密码不能为空!");
        return NO;
    }
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:userName] == NO)
    {
        AlertContent(@"邮箱格式不对!");
        return NO;
    }
    
    return YES;
}
- (void)handleBtnAction:(UIButton*)sender
{
    NSString* userName = _userName.text;
    NSString* passWord = _passWord.text;
    
    UserModel* userSelf = nil;
    if (sender.tag == 6998)
        userSelf = [NetWorkConnect.sharedInstance userRegisterWithName:userName
                                                              passWord:[NSString md5HexDigest:passWord]
                                                              userType:UserTypeRegister
                                                                gender:GenderTypeBoy
                                                               headImg:nil
                                                           description:nil];
    else
        userSelf = [[NetWorkConnect sharedInstance] userLogInWithToken:[NSString md5HexDigest:passWord]
                                                              userType:UserTypeRegister
                                                          userIdentity:userName];
    
    [SVProgressHUD dismiss];
    if (userSelf) //login successful
    {
        NSLog(@"user register log in successful!");
        
        [[NSUserDefaults standardUserDefaults] setBool:YES       forKey:kUserLogIn];
        [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:kLogInToken];
        [[NSUserDefaults standardUserDefaults] setInteger:UserTypeRegister forKey:kLogInType];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kUserIdentity];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        if (userSelf.area == nil)
        {
            SelectZoneViewController* selectZoneVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SelectZoneVCIdentifier"];
            selectZoneVC.firstSelect = YES;
            
            [[UIApplication sharedApplication].keyWindow setRootViewController:selectZoneVC];
        }
        else
        {
            NSMutableArray* zoneIds = [NSMutableArray array];
            for (AreaModel* area in userSelf.areas)
            {
                [zoneIds addObject:[NSString stringWithFormat:@"%d", area.area_id]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:zoneIds forKey:kSelectZones];
            
            [[NSUserDefaults standardUserDefaults] setInteger:userSelf.area.area_id forKey:kUserAreaId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            HomePageViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:homeVC];
        }
    }
}
- (BOOL)checkQQInstalled
{
    if ([TencentOAuth iphoneQQInstalled])
    {
        NSLog(@"QQ is installed");
        return YES;
    }
    else
    {
        NSLog(@"QQ is not installed");
        return NO;
    }
}
@end

//
//  RegAndLoginViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-30.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "RegAndLoginViewController.h"



#define kUserNameTFTag 9000
#define kPassWordTFTag 8999
@interface RegAndLoginViewController () <UITextFieldDelegate>
{
    
    BOOL userNameValidateRes;
    BOOL passWordValidateRes;
    
}


@property (nonatomic, retain) TencentOAuth *tencentOAuth;
@property (nonatomic, retain) NSArray* permissions;
@end

@implementation RegAndLoginViewController

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
    [self.zhangHaoTextfield becomeFirstResponder];
    if (IOS_NEWER_OR_EQUAL_TO_7)
        self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view.
    if (_isRegister) {
        [_actionBtn setTitle:@"加入" forState:UIControlStateNormal];
        self.title = @"创建用户";
    } else {
        [_actionBtn setTitle:@"登录" forState:UIControlStateNormal];
        self.title = @"登录";
    }
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _userNameTF.frame.size.height)];
    leftView1.backgroundColor = _userNameTF.backgroundColor;
    _userNameTF.leftView = leftView1;
    _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _passWordTF.frame.size.height)];
    leftView2.backgroundColor = _passWordTF.backgroundColor;
    _passWordTF.leftView = leftView2;
    _passWordTF.leftViewMode = UITextFieldViewModeAlways;
    
    [_userNameHintLabel setTextColor:UIColorFromRGB(0xff2d2d)];
    [_passWordHintLabel setTextColor:UIColorFromRGB(0xff2d2d)];
    
    [_passWordTF setBackgroundColor:UIColorFromRGB(0xe3e4e6)];
    
    [_userNameTF setTextColor:UIColorFromRGB(0x4c5159)];
    [_passWordTF setTextColor:UIColorFromRGB(0x9da1a6)];
    
    [_userNameTF setTag:kUserNameTFTag];
    [_userNameTF addTarget:self action:@selector(validateField:) forControlEvents:UIControlEventEditingChanged];
    [_passWordTF setTag:kPassWordTFTag];
    [_passWordTF addTarget:self action:@selector(validateField:) forControlEvents:UIControlEventEditingChanged];
    [_passWordTF setDelegate:self];
    
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self.scrollView setScrollEnabled:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    userNameValidateRes = NO;
    passWordValidateRes = NO;
    
    
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}
- (IBAction)zhangHaoTextfield:(id)sender {
    [self.miMaTextfield becomeFirstResponder];
}
- (IBAction)miMaTexefield:(id)sender {
    [self.miMaTextfield resignFirstResponder];
}
- (IBAction)QQdown:(id)sender {
    NSLog(@"QQ dengru ");
    [_tencentOAuth authorize:_permissions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)validateField:(UITextField*)textField {
    if (textField.tag == kUserNameTFTag) {
        NSInteger userNameLength = _userNameTF.text.length;
        if (userNameLength <2 || userNameLength > 16) {
            _userNameHintLabel.text = @"请输入2-16位字符";
            userNameValidateRes = NO;
        } else {
            _userNameHintLabel.text = @"";
            userNameValidateRes = YES;
        }
    } else {
        if (_passWordTF.text.length < 6) {
            passWordValidateRes = NO;
            _passWordHintLabel.text = @"密码至少6位";
        } else {
            passWordValidateRes = YES;
            _passWordHintLabel.text = @"";
        }
    }
}
- (IBAction)handleBtnPressed:(id)sender {
    if (!userNameValidateRes || !passWordValidateRes) {
        return;
    }
    
    NSDictionary* result = nil;
    if (_isRegister) { //注册
        result = [NetWorkConnect.sharedInstance userRegisterWithName:_userNameTF.text
                                                              passWord:[NSString md5HexDigest:_passWordTF.text]
                                                              userType:UserTypeRegister
                                                                gender:GenderTypeBoy
                                                               headImg:nil
                                                           description:nil];
    } else { //登陆
        result = [[NetWorkConnect sharedInstance] userLogInWithUserNameAndPassWord:_userNameHintLabel.text
                                                                           password:_passWordHintLabel.text];
    }
    UserModel* userSelf = [result objectForKey:@"userModel"];
    NSLog(@"%@",userSelf);
    if (userSelf) //login successful
    {
        NSLog(@"user register log in successful!");
        [USER_DEFAULT setObject:userSelf.easemob_name forKey:kSelfHuanXinId];
        [USER_DEFAULT setObject:userSelf.easemob_pwd  forKey:kSelfHuanXinPW];
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userSelf.easemob_name
                                                            password:userSelf.easemob_pwd
                                                          completion:nil onQueue:nil];
        
        NSMutableSet *tags = [NSMutableSet set];
        [tags addObject:@"online"];
        for(AreaModel* area in userSelf.areas)
            [tags addObject:[NSString stringWithFormat:@"%d", area.area_id]];
        [APService setTags:tags
                     alias:[NSString stringWithFormat:@"%ld", userSelf.user_id]
          callbackSelector:nil
                    target:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES       forKey:kUserLogIn];
        [[NSUserDefaults standardUserDefaults] setObject:_passWordTF.text forKey:kLogInToken];
        [[NSUserDefaults standardUserDefaults] setInteger:UserTypeRegister forKey:kLogInType];
        [[NSUserDefaults standardUserDefaults] setObject:_userNameTF.text forKey:kUserName];
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
            
            BannerViewController* bannerVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TabBarVCIdentifier"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:bannerVC];
        }
    }
    else
    {
        if (_isRegister) {
            _userNameHintLabel.text = result[@"error"];
        } else {
            _passWordHintLabel.text = result[@"error"];
        }
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 50) animated:YES];
}
@end

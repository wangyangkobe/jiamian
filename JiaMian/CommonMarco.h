//
//  CommonMarco.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#ifndef JiaMian_CommonMarco_h
#define JiaMian_CommonMarco_h

//#define HOME_PAGE  @"http://114.215.109.246/MaskTech"
#define HOME_PAGE  @"http://115.29.102.106/MaskTechDEV"

#define kUserLogIn     @"kUserLogIn"
#define kLogInToken    @"kLogInToken"
#define kLogInUserId   @"kLogInUserId"
#define kLogInType     @"kLogInType"
#define kUserAreaId    @"kUserAreaId"
#define kUserName      @"kUserName"
#define kSelectZones   @"kSelectZones"
#define kCongigureDict @"kCongigureDict"

#define kSelfUserModel @"kSelfUserModel"

// Alert Config
#define kAlertShake  @"kAlertShake"
#define kAlertSound  @"kAlertSound"

//Sina WeiBo
#define kSinaAppKey         @"862234629"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"

//Tencen QQ
#define kTencentQQAppKey        @"101072460"
#define kTencentQQKey           @"bda4419002858fb94d03da4db280900c"
#define kTencentQQRedirectURI   @"www.qq.com"

//WeChat
#define kWeChatAppId    @"wx8839986cd11a188f"

//友盟
#define kUMengAppKey    @"535e5f0256240baa89078c7f"

//-------------------七牛-------------------------
#define QiniuAccessKey  @"89DgnUvGmfOxOBnQeVn1z99ypLdGoC2JKsvs8aOU"
#define QiniuSecretKey  @"FsTqp2yKJwtz5dI9vjhmzK16K6X8r9dzDa65mf23"
#define QiniuBucketName @"jiamiantechtest"
#define QiniuDomian     [NSString stringWithFormat:@"http://%@.qiniudn.com/", QiniuBucketName]

#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

//获取屏幕 宽度、高度
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//NavBar高度
#define NavigationBar_HEIGHT 44
//ToolBar 高度
#define TOOLBAR_HEIGHT 44
//键盘高度
#define KEYBOARD_HEIGHT 216

#define StatusBarHeight 20

typedef NS_ENUM(NSInteger, MessageType)
{
	MessageTypeText  = 1,
	MessageTypeVoice = 2,
};

typedef NS_ENUM(NSInteger, GenderType)
{
	GenderTypeNone = 0,
	GenderTypeBoy  = 1,
	GenderTypeGirl = 2,
};

typedef NS_ENUM(NSInteger, UserType)
{
	UserTypeQQ       = 1,
	UserTypeWeiBo    = 2,
    UserTypeRegister = 3
};

typedef NS_ENUM(NSInteger, BackGroundImageType)
{
	BackGroundWithoutImage = 1,  //无图片
	BackGroundWithImage    = 2,  //图片
};

typedef NS_ENUM(NSInteger, ZoneType)
{
	ZoneTypeSchool   = 1,  //学校
	ZoneTypeIndustry = 2,  //行业
    ZoneTypeCompany  = 3   //公司
};

#define RGBCOLOR(r,g,b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSInteger COLOR_ARR[] = {0, 0x6683c4, 0x2bad94, 0x8ab147, 0xacc551, 0xeac851, 0xe4847f, 0xeb977a, 0xb086c1, 0x505050, 0x7bc3c7};

#define FONT(x) [UIFont systemFontOfSize:x]
#define USER_DEFAULT [NSUserDefaults standardUserDefaults];


#define AlertContent(content) \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" \
message:content \
delegate:nil \
cancelButtonTitle:@"确定" \
otherButtonTitles:nil]; \
[alert show]; \

#endif

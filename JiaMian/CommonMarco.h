//
//  CommonMarco.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#ifndef JiaMian_CommonMarco_h
#define JiaMian_CommonMarco_h

#define HOME_PAGE  @"http://114.215.109.246/MaskTechDEV"

#define kUserLogIn     @"kUserLogIn"
#define kLogInToken    @"kLogInToken"
#define kLogInUserId   @"kLogInUserId"
#define kLogInType     @"kLogInType"
#define kUserAreaId    @"kUserAreaId"

#define kSelfUserModel @"kSelfUserModel"
//Sina WeiBo
#define kSinaAppKey         @"862234629"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"

//Tencen QQ
#define kTencentQQAppKey        @"101072460"
#define kTencentQQRedirectURI   @"www.qq.com"

//WeChat
#define kWeChatAppId    @"wx8839986cd11a188f"

//友盟
#define kUMengAppKey    @"535e5f0256240baa89078c7f"


#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

//获取屏幕 宽度、高度
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//NavBar高度
#define NavigationBar_HEIGHT 44
//ToolBar 高度
#define TOOLBAR_HEIGHT 40
//键盘高度
#define KEYBOARD_HEIGHT 216

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
	UserTypeQQ    = 1,
	UserTypeWeiBo = 2,
};

typedef NS_ENUM(NSInteger, BackGroundType)
{
	BackGroundTypeNum = 1,  //序号
	BackGroundTypeUrl = 2,  //图片URL
};

#define RGBCOLOR(r,g,b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSInteger COLOR_ARR[] = {0, 0xf1f1f1, 0xffff66, 0x000000, 0x24b1ce, 0xff9999, 0x99CC66, 0xCC3399, 0xfe4a4a, 0xCC3333};

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

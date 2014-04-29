//
//  CommonMarco.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#ifndef JiaMian_CommonMarco_h
#define JiaMian_CommonMarco_h

#define HOME_PAGE  @""
#define kUserLogIn @"kUserLogIn"
//Sina WeiBo
#define kSinaAppKey         @"862234629"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"

//Tencen QQ
#define kTencentQQAppKey        @"101072460"
#define kTencentQQRedirectURI   @"www.qq.com"

//友盟
#define kUMengAppKey    @"535e5f0256240baa89078c7f"


#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

#define kTextLabel    8000
#define kAreaLabel    8001
#define kCommentLabel 8002

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

#endif

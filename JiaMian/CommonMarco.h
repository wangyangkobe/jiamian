//
//  CommonMarco.h
//  JiaMian
//
//  Created by wy on 14-4-26.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#ifndef JiaMian_CommonMarco_h
#define JiaMian_CommonMarco_h

//Sina WeiBo
#define kSinaAppKey         @"4192641502"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"

//Tencen QQ
#define kTencentQQAppKey        @"101073013"
#define kTencentQQRedirectURI   @"www.qq.com"

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

#endif

//
//  ErrorModel.h
//  JiaMian
//
//  Created by wy on 14-5-2.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface ErrorModel : JSONModel
@property(strong, nonatomic) NSString* err_code;
@property(strong, nonatomic) NSString* err_msg;
@end
//
//  UIView+Extensions.h
//  JiaMian
//
//  Created by wanyang on 14-7-21.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extensions)
+ (void)animateForVisibleNumberInView:(UIView*)view;
+ (UITableViewCell*)tableViewCellFromTapGestture:(UITapGestureRecognizer*)gesture;
+ (UIView*)configureMoreViewWithBtns:(NSArray*)btnsConf;
@end

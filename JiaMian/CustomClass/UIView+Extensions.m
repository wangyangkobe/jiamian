//
//  UIView+Extensions.m
//  JiaMian
//
//  Created by wanyang on 14-7-21.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)
+ (void)animateForVisibleNumberInView:(UIView*)view
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setText:@"可见人数+50"];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label sizeToFit];
    label.center = CGPointMake(250, 285);
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [view addSubview:label];
        label.center = CGPointMake(250, 250);
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}
@end

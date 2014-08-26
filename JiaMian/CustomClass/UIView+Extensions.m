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
+ (UITableViewCell*)tableViewCellFromTapGestture:(UITapGestureRecognizer*)gesture
{
    UIView* view = (UIView*)[gesture view];
    while (view != nil) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell*)view;
        } else {
            view = [view superview];
        }
    }
    return nil;
}
+ (UIView*)configureMoreView:(NSArray*)btnsConf
{
    UIView* moreView = [[self alloc] initWithFrame:CGRectMake(195, 190, 120, 100)];
    [moreView setBackgroundColor:[UIColor lightGrayColor]];
    for (int i = 0; i < btnsConf.count; i++) {
        NSDictionary* confDict = btnsConf[i];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i*30 + 10, 120, 20)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setTitle:confDict[@"title"] forState:UIControlStateNormal];
        [btn addTarget:confDict[@"target"]
                action:NSSelectorFromString(confDict[@"selector"])
      forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:btn];
    }
    return moreView;
}
+ (UIView*)configureJuBaoView:(NSArray *)btnsConf
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(80, 80, 160, 160)];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
    [label setText:@"举报与屏蔽"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
    for (int i = 0; i < btnsConf.count; i++)
    {
        NSDictionary* confDict = btnsConf[i];
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + i*40, 160, 30)];
        [[btn layer] setBorderWidth:1.0f];
        [[btn layer] setBorderColor:[UIColor greenColor].CGColor];
        [btn setTitle:confDict[@"title"] forState:UIControlStateNormal];
        [btn addTarget:confDict[@"target"]
                action:NSSelectorFromString(confDict[@"selector"])
      forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    return view;
}
@end

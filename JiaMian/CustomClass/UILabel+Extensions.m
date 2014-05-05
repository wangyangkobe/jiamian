//
//  UILabel+Extensions_h.m
//  JiaMian
//
//  Created by wy on 14-5-5.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "UILabel+Extensions.h"

@implementation UILabel (Extensions)

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth lines:(int)lineNumbers
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    self.numberOfLines = lineNumbers;
    [self sizeToFit];
}
@end

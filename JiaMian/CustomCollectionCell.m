//
//  CustomCollectionCell.m
//  JiaMian
//
//  Created by wy on 14-6-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "CustomCollectionCell.h"
@interface CustomCollectionCell ()
{
    CAShapeLayer* _border;
}
@end
@implementation CustomCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    //self.layer.borderColor =[UIColor darkGrayColor].CGColor;
    //self.layer.borderWidth = 1;

    self.backgroundColor = UIColorFromRGB(0xd2d2d2);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_dashedBorder)
    {
        _border = [CAShapeLayer layer];
        UIColor* borderColor = UIColorFromRGB(0x93928e);
        _border.strokeColor = borderColor.CGColor;
        _border.fillColor = nil;
        _border.lineDashPattern = @[@4, @2];
        [_border setLineWidth:5];
        [self.layer addSublayer:_border];
        
        CGSize frameSize = self.frame.size;
        CGRect shapeRect = CGRectMake(0.0f, 0.0f, 100, 100);
        [_border setBounds:shapeRect];
        [_border setPosition:CGPointMake( frameSize.width/2,frameSize.height/2)];
        
        _border.path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:50.0].CGPath;
        //  _border.frame = self.bounds;
    }
}


@end

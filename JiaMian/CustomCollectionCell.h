//
//  CustomCollectionCell.h
//  JiaMian
//
//  Created by wy on 14-6-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *zoneName;
@property (assign, nonatomic, getter = isDashedBorder) BOOL dashedBorder;

@end

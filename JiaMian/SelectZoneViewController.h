//
//  SelectZoneViewController.h
//  JiaMian
//
//  Created by wy on 14-6-8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectZoneViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)loadMoreBtnPress:(id)sender;

@end

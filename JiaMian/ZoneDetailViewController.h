//
//  ZoneDetailViewController.h
//  JiaMian
//
//  Created by wy on 14-6-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZoneDetailViewController;

@protocol ZoneDetailVCDelegate <NSObject>
-(void)zoneDetailViewController:(ZoneDetailViewController*)viewController didFinishSelectZone:(AreaModel*)zone;
@end

@interface ZoneDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, weak) id<ZoneDetailVCDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDispalyController;

@property (assign, nonatomic) NSInteger zoneType;

@end

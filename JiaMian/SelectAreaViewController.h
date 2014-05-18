//
//  SelectAreaViewController.h
//  JiaMian
//
//  Created by wy on 14-5-18.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAreaViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger lastSelectedIndex;
@property (assign, nonatomic, getter = isFirstSelect) BOOL firstSelect;
@end

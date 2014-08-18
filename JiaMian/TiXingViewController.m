//
//  TiXingViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-17.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "TiXingViewController.h"

@interface TiXingViewController ()

@property (nonatomic, strong) UIViewController* currentVC;
@end

@implementation TiXingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    self.view = view;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"回复", @"私信", @"通知"]];
    [segmentedControl setFrame:CGRectMake(30, 5, 260, 30)];
    [segmentedControl setSelectedSegmentIndex:_selectSegementIndex];
    [segmentedControl addTarget:self action:@selector(segmentedControlHasChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    _currentVC = [self viewControllerForSegmentIndex:_selectSegementIndex];
    if (_selectSegementIndex == 0)
    {
        UnReadMsgViewController* unreadMsgVC = (UnReadMsgViewController*)_currentVC;
        CGRect oldFrame = unreadMsgVC.view.frame;
        [unreadMsgVC.view setFrame:CGRectMake(0, 40, SCREEN_WIDTH, oldFrame.size.height - 100)];
        [self addChildViewController:unreadMsgVC];
        [self.view addSubview:unreadMsgVC.view];
        [unreadMsgVC didMoveToParentViewController:self];
    }
    else if (1 == _selectSegementIndex)
    {
        SiXinViewController* siXinVC = (SiXinViewController*)_currentVC;
        CGRect oldFrame = siXinVC.view.frame;
        [siXinVC.view setFrame:CGRectMake(0, 40, SCREEN_WIDTH, oldFrame.size.height - 100)];
        [self addChildViewController:siXinVC];
        [self.view addSubview:siXinVC.view];
        [siXinVC didMoveToParentViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlHasChangedValue:(UISegmentedControl*)sender
{
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentVC toViewController:vc duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                                   [self.currentVC.view removeFromSuperview];
                                   vc.view.frame = CGRectMake(0, 40, SCREEN_WIDTH, 300);
                                   [self.view addSubview:vc.view];
                               } completion:^(BOOL finished) {
                                   [vc didMoveToParentViewController:self];
                                   [self.currentVC removeFromParentViewController];
                                   self.currentVC = vc;
                               }];
    self.navigationItem.title = vc.title;
}
- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    switch (index) {
        case 0:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UnReadMsgVCIdentifier"];
            break;
        case 1:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SiXinVCIdentifier"];
            break;
        case 2:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UnReadMsgVCIdentifier"];
            break;
    }
    return vc;
}
@end

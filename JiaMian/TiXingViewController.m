//
//  TiXingViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-17.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "TiXingViewController.h"
#import "HMSegmentedControl.h"

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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"回复", @"私信"]];
    [segmentedControl setSelectionIndicatorHeight:2.0f];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.frame = CGRectMake(80, 40, 130, 30);
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [segmentedControl addTarget:self action:@selector(segmentedControlHasChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView=segmentedControl;
    
    //设置不透明
    if (IOS_NEWER_OR_EQUAL_TO_7)
        self.navigationController.navigationBar.translucent = NO;
    
    _currentVC = [self viewControllerForSegmentIndex:_selectSegementIndex];
    [_currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.view.bounds) - 44)];
    [self addChildViewController:_currentVC];
    [self.view addSubview:_currentVC.view];
    [_currentVC didMoveToParentViewController:self];
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
                                   vc.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.view.bounds));
                                   [self.view addSubview:vc.view];
                               } completion:^(BOOL finished) {
                                   [vc didMoveToParentViewController:self];
                                   [self.currentVC removeFromParentViewController];
                                   self.currentVC = vc;
                               }];
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    switch (index) {
        case 0:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HuiFuVCIdentifier"];
            break;
        case 1:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChatListVCIdentifier"];
            break;
    }
    return vc;
}
@end

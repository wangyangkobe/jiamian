//
//  ShowInfoViewController.m
//  JiaMian
//
//  Created by wy on 14-6-17.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ShowInfoViewController.h"

@interface ShowInfoViewController ()

@end

@implementation ShowInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGRect statusBarFrame  = [[UIApplication sharedApplication] statusBarFrame]; //height = 20
    
    //创建UINavigationBar
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + statusBarFrame.size.height)];
        UIScrollView* srollView = (UIScrollView *)[[self.webView subviews] objectAtIndex:0];
        [srollView setContentInset:UIEdgeInsetsMake(statusBarFrame.size.height, 0, 0, 0)];
    }
    else
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    navigationBar.delegate = self;
    //创建UINavigationItem
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"最终用户许可协议"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backBarBtn:)];
    
    navigationItem.leftBarButtonItem = leftBtnItem;
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"eula" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile: htmlPath];
    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.webView loadHTMLString:info baseURL:[NSURL fileURLWithPath: htmlPath]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBarBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

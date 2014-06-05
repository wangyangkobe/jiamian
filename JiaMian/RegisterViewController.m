//
//  RegisterViewController.m
//  JiaMian
//
//  Created by wy on 14-6-4.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "RegisterViewController.h"
#import "LogInViewController.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        [self.scrollView setContentOffset:CGPointMake(0, -20)];
    }
    
   // [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, 1.1 * SCREEN_HEIGHT)];
    UITapGestureRecognizer* tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:tapViewGesture];
}
- (void)dismissKeyBoard:(UIGestureRecognizer*)gesture
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnBtnPress:(id)sender
{
    LogInViewController* logInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:logInVC];
}

- (IBAction)forgetPassWord:(id)sender
{
    AlertContent(@"请联系admin@jiamiantech.com");
}
@end

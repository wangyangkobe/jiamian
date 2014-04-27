//
//  MessageDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "TableHeaderView.h"
@interface MessageDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    CGFloat headerViewHeight;
    NSMutableArray* commentArr;
    
    UITextField* textField;
    UIButton*    sendButton;  //发送按钮
}

@end

@implementation MessageDetailViewController

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
    
    UIBarButtonItem* shareMessageBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"分享"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(shareMsgBtnPressed:)];
    self.navigationItem.rightBarButtonItem = shareMessageBarBtn;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    commentArr = [NSMutableArray array];
    
    
    self.tableView.tableHeaderView = [self configureTableHeaderView];
    [self configureToolBar];
}
- (void)shareMsgBtnPressed:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView*)configureTableHeaderView
{
    TableHeaderView*  myHeader = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView"
                                                                owner:self
                                                              options:nil] objectAtIndex:0];
    CGFloat textHeight = [NSString textHeight:self.msgText
                                 sizeWithFont:[UIFont systemFontOfSize:17]
                            constrainedToSize:CGSizeMake(240, 9999)];
    headerViewHeight = textHeight + 15 + 50;
    CGRect headerFrame = myHeader.frame;
    headerFrame.size.height = headerViewHeight;
    myHeader.frame = headerFrame;
    myHeader.textLabel.text = self.msgText;
    myHeader.areaLabel.text = @"华东理工";
    myHeader.commentNumLabel.text = [NSString stringWithFormat:@"%d", 1];
    return myHeader;
}
#pragma mark UITableViewDelgate
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//
//    CGFloat textHeight = [NSString textHeight:self.msgText
//                                 sizeWithFont:[UIFont systemFontOfSize:17]
//                            constrainedToSize:CGSizeMake(240, 9999)];
//    headerViewHeight = textHeight + 15 + 50;
//    NSLog(@"%s, %lf", __FUNCTION__, textHeight);
//    return headerViewHeight;
//
//}
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//
//    static NSString *HeaderIdentifier = @"HeaderViewIdentifier";
//    TableHeaderView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
//    if(!myHeader)
//    {
//        myHeader = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView"
//                                                  owner:self
//                                                options:nil] objectAtIndex:0];
//    }
//    myHeader.textLabel.text = self.msgText;
//    myHeader.areaLabel.text = @"华东理工";
//    myHeader.commentNumLabel.text = [NSString stringWithFormat:@"%d", 1];
//    [myHeader setNeedsLayout];
//    return myHeader;
//
//
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"CommentCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"我的朋友是极品....";
    cell.detailTextLabel.text = @"1楼，5小时前";
    return cell;
}

- (void)configureToolBar
{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 7, 275, 30)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:13.0f];
    textField.backgroundColor = [UIColor whiteColor];
    textField.returnKeyType = UIReturnKeySend;
    [self.toolBar addSubview:textField];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(280, 7, 40, 30)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendCommentMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:sendButton];
    
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark 监听键盘的显示与隐藏
- (void)inputKeyboardWillShow:(NSNotification *)notification
{
    NSLog(@"call: %s", __FUNCTION__);
    CGRect keyBoardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //键盘显示，设置toolbar的frame跟随键盘的frame
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        [self.toolBar setFrame:CGRectMake(0, keyBoardFrame.origin.y - 44 - 40 - 20, 320, 44)];
    }];
}

- (void)inputKeyboardWillHide:(NSNotification *)notification
{
    NSLog(@"call: %s", __FUNCTION__);
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        [self.toolBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 44 - 40 - 20, SCREEN_WIDTH, TOOLBAR_HEIGHT)];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"call: %@", NSStringFromSelector(_cmd));
    return TRUE;
}
- (void)sendCommentMessage:(id)sender
{
    [self.view endEditing:YES];
}
@end

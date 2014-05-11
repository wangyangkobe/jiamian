//
//  PublishMsgViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "PublishMsgViewController.h"

@interface PublishMsgViewController () <UITextViewDelegate>
{
    UIActivityIndicatorView* indicatorView;
}
@end

@implementation PublishMsgViewController

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
    
    self.textView.delegate = self;
    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    NSMutableAttributedString* hoderText = [[NSMutableAttributedString alloc] initWithString:@"匿名发表心中所想吧"];
    [hoderText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(0, [hoderText length])];
    [hoderText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [hoderText length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [hoderText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [hoderText length])];
    //self.textView.contentInset = UIEdgeInsetsMake(90, 70, 0, 0);
    if (IOS_NEWER_OR_EQUAL_TO_7)
        [self.textView  setTextContainerInset:UIEdgeInsetsMake(0, 40, 0, 40)];
    self.textView.attributedPlaceholder = hoderText;
    [self.textView becomeFirstResponder];
    
    UIBarButtonItem* sendMessageBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(sendMsgBtnPressed:)];
    self.navigationItem.rightBarButtonItem = sendMessageBarBtn;
    
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setFrame:CGRectMake(260, 100, 50, 50)];
    indicatorView.hidesWhenStopped = YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%s, range = %@", __FUNCTION__, NSStringFromRange(range));
    if ( (range.location > 160) || (textView.text.length > 160) )  //控制输入文本的长度
        return NO;
    else
        return YES;
}
- (void)sendMsgBtnPressed:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    [indicatorView startAnimating];
    MessageModel* message = [[NetWorkConnect sharedInstance] messageCreate:self.textView.text msgType:MessageTypeText areaId:1 lat:0.0 lon:0.0];
    if (message)
    {
        [indicatorView stopAnimating];
        //通知父视图获取最新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"publishMessageSuccess" object:self userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES ];
    }
}
- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}
@end

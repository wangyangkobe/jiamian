//
//  PublishMsgViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "PublishMsgViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PublishMsgViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIActivityIndicatorView* indicatorView;
    UIImage* selectedImage;
}
@property (nonatomic, strong) UIToolbar* toolBar;
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.textView.delegate = self;
    
    [self.textView.layer setBorderColor: [[UIColor grayColor] CGColor]];    
    [self.textView.layer setBorderWidth: 1.0];    
    //[self.textView.layer setCornerRadius:8.0f];    
    [self.textView.layer setMasksToBounds:YES];

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
    
    [self configureToolBar];
    [self.view addSubview:_toolBar];
    [self.textView setInputAccessoryView:_toolBar];
    
    CGRect oldFrame = self.textView.frame;
    [self.textView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.width)];
    self.bgImageView.frame = self.textView.frame;
   // [self.bgImageView setContentMode:UIViewContentModeScaleAspectFit];
    NSLog(@"imageView frame = %@", NSStringFromCGRect(self.bgImageView.frame));
    NSLog(@"textView frame = %@", NSStringFromCGRect(self.textView.frame));
    NSLog(@"screen frame = %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
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
    if ( (range.location > 160) || (textView.text.length > 160) )  //控制输入文本的长度
        return NO;
    else
        return YES;
}
- (void)sendMsgBtnPressed:(id)sender
{
    [indicatorView startAnimating];
    long areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
    NSLog(@"%s, areaId = %ld", __FUNCTION__, (long)areaId);
    MessageModel* message = [[NetWorkConnect sharedInstance] messageCreate:self.textView.text
                                                                   msgType:MessageTypeText
                                                                    areaId:areaId
                                                                       lat:0.0
                                                                       lon:0.0];
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


- (void)configureToolBar
{
    if (_toolBar == nil)
    {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH - 44, SCREEN_WIDTH, 44)];
        _toolBar.items = [NSArray arrayWithObjects:
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraBtnPressed:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          nil];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_toolBar sizeToFit];
    }
}

- (void)cameraBtnPressed:(id)sender
{
    [self.textView becomeFirstResponder];
    UIActionSheet* chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    [chooseImageSheet showInView:self.view];
}

-(void)doneWithKeyboard:(id)sender
{
    
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (2 == buttonIndex) //取消
        return;
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (0 == buttonIndex) //拍照
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        else
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if(1 == buttonIndex)
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(id)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    NSDictionary* mediaInfoArray = (NSDictionary *)info;
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), [mediaInfoArray description]);
    
    selectedImage = [mediaInfoArray objectForKey:UIImagePickerControllerEditedImage];
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        CGRect oldFrame = self.textView.frame;
        [self.bgImageView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH, SCREEN_WIDTH)];
        self.textView.frame = self.bgImageView.frame;
    }
    [self.bgImageView setImage:selectedImage];
    [self.textView setTextColor:UIColorFromRGB(0xffffff)];
    NSLog(@"imageView frame = %@", NSStringFromCGRect(self.bgImageView.frame));
    [self.textView becomeFirstResponder];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.textView becomeFirstResponder];
    }];
}
@end

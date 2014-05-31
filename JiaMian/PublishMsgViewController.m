//
//  PublishMsgViewController.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "PublishMsgViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extensions.h"

static NSString* placeHolderText = @"匿名发表心中所想吧";

@interface PublishMsgViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, QiniuUploadDelegate>
{
    UIImage* selectedImage;
    QiniuSimpleUploader* qiNiuUpLoader;
    NSString* imagePath;
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
    [self.textView setScrollEnabled:YES];
    [self.textView setUserInteractionEnabled:YES];
    
    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

    [self configurePlaceHolderText:placeHolderText withColor:[UIColor darkGrayColor]];
    [self configureToolBar];
    [self.view addSubview:_toolBar];
    [self.textView setInputAccessoryView:_toolBar];
    
    CGRect oldFrame = self.textView.frame;
    [self.textView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.width)];
    self.backgroundImageView.frame = self.textView.frame;

    //    [self.textView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    //    [self.textView.layer setBorderWidth: 5.0];
    //    [self.textView.layer setCornerRadius:8.0f];
    //    [self.textView.layer setMasksToBounds:YES];
    
    UIBarButtonItem* sendMessageBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(sendMsgBtnPressed:)];
    self.navigationItem.rightBarButtonItem = sendMessageBarBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve    = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
    CGRect oldFrame = _textView.frame;
    CGFloat viewHeight = self.view.bounds.size.height;
    _textView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH, viewHeight - keyboardBounds.size.height);
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        _textView.contentSize = _textView.frame.size;
    }
    
	[UIView commitAnimations];
}
- (void)keyboardWillHide:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        _textView.contentSize = _textView.frame.size;
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"call %s", __FUNCTION__);
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    long areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
    NSLog(@"%s, areaId = %ld", __FUNCTION__, (long)areaId);
    
    BackGroundImageType backgroudType = ( (imagePath == nil) ? BackGroundWithoutImage : BackGroundWithImage );
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageCreate:self.textView.text
                                                                   msgType:MessageTypeText
                                                                    areaId:areaId
                                                                    bgType:backgroudType
                                                                  bgNumber:-1
                                                                     bgUrl:imagePath
                                                                       lat:0.0
                                                                       lon:0.0];
    if (message)
    {
        //通知父视图获取最新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"publishMessageSuccess" object:self userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES ];
    }
}
- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (void)configurePlaceHolderText:(NSString*)text withColor:(UIColor*)color
{
    NSMutableAttributedString* hoderText = [[NSMutableAttributedString alloc] initWithString:text];
    [hoderText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(0, [hoderText length])];
    [hoderText addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [hoderText length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [hoderText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [hoderText length])];
    if (IOS_NEWER_OR_EQUAL_TO_7)
        [self.textView  setTextContainerInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    self.textView.attributedPlaceholder = hoderText;
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
   // [self.textView becomeFirstResponder];
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
    selectedImage = [mediaInfoArray objectForKey:UIImagePickerControllerEditedImage];
    
    CGRect oldFrame = self.textView.frame;
    [self.backgroundImageView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH, SCREEN_WIDTH)];
    self.textView.frame = self.backgroundImageView.frame;
    
    [self.backgroundImageView setImage:selectedImage];
    [self.textView setTextColor:UIColorFromRGB(0xffffff)];
    
   // [self.textView resignFirstResponder];
    [self.textView becomeFirstResponder];
    
    [self.textView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackalpha"]]];
    [self configurePlaceHolderText:placeHolderText withColor:[UIColor whiteColor]];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        imagePath = [UIImage saveImage:selectedImage withName:@"fuck"];
        [self uploadFile:imagePath bucket:QiniuBucketName key:[NSString generateQiNiuFileName]];
    });
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.textView becomeFirstResponder];
    }];
}


#pragma mark - QiniuUploadDelegate
- (void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
    NSString* path = [QiniuDomian stringByAppendingString:[ret objectForKey:@"key"]];
    imagePath = path;
}
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    if ([QiniuAccessKey hasPrefix:@"<Please"])
    {
        NSLog(@"Please replace kAccessKey, kSecretKey and kBucketName with proper values.");
    }
    else
    {
        NSLog(@"upload image file to QiNiu failded!");
        //继续重传
        [self uploadFile:filePath bucket:QiniuBucketName key:[NSString generateQiNiuFileName]];
    }
}
- (NSString *)tokenWithScope:(NSString *)scope
{
    QiniuPutPolicy* policy = [QiniuPutPolicy new] ;
    policy.scope = scope;
    return [policy makeToken:QiniuAccessKey secretKey:QiniuSecretKey];
}

- (void)uploadFile:(NSString *)filePath bucket:(NSString *)bucket key:(NSString *)key
{
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath])
    {
        if(qiNiuUpLoader == nil)
            qiNiuUpLoader = [QiniuSimpleUploader uploaderWithToken:[self tokenWithScope:bucket]];
        qiNiuUpLoader.delegate = self;
        [qiNiuUpLoader uploadFile:filePath key:key extra:nil];
    }
}
@end

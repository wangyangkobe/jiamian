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
#import "SVProgressHUD.h"
static NSString* placeHolderText = @"匿名发表心中所想吧";

@interface PublishMsgViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, QiniuUploadDelegate>
{
    UIImage* selectedImage;
    QiniuSimpleUploader* qiNiuUpLoader;
    NSString* imagePath;
    NSString* qiNiuImagePath;
    CGRect previouRect;
    NSInteger lineNumbers;
    
    int selectIndex;
    
    NSMutableArray* selectZoneNames;
    NSMutableDictionary* indexMapZoneName;
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
    
    CGRect oldFrame = _textView.frame;
    _textView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, 320, 320);
    _textView.contentSize = _textView.frame.size;
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
    
    previouRect = CGRectZero;
    lineNumbers = 0;
    
    self.textView.delegate = self;
    [self.textView setScrollEnabled:YES];
    [self.textView setUserInteractionEnabled:YES];
    
    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self configurePlaceHolderText:placeHolderText withColor:[UIColor darkGrayColor]];
    [self configureToolBar];
    [self.view addSubview:_toolBar];
    [self.textView setInputAccessoryView:_toolBar];
    
    UISwipeGestureRecognizer* hiddenKeyBoard = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard:)];
    [hiddenKeyBoard setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.textView addGestureRecognizer:hiddenKeyBoard];
    
    //    CGRect oldFrame = self.textView.frame;
    //    [self.textView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH, SCREEN_WIDTH)];
    //    self.backgroundImageView.frame = self.textView.frame;
    
//    [self.textView.layer setBorderColor: [[UIColor grayColor] CGColor]];
//    [self.textView.layer setBorderWidth: 1.0];
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
    
    selectZoneNames = [NSMutableArray array];
    indexMapZoneName = [NSMutableDictionary dictionary];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* zoneIdArr = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectZones];
        int temp = 0;
        for (id zoneId in zoneIdArr)
        {
            AreaModel* zone = [[NetWorkConnect sharedInstance] areaShowByAreaId:[zoneId integerValue]];
            [selectZoneNames addObject:[NSDictionary dictionaryWithObjectsAndKeys:zone.area_name, @"text", nil]];
            [indexMapZoneName setObject:[NSNumber numberWithInt:zone.area_id] forKey:[NSString stringWithFormat:@"%d", temp]];
            temp++;
        }
    });
}
- (void)hiddenKeyBoard:(UISwipeGestureRecognizer*)gesture
{
    [self.textView resignFirstResponder];
}
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber* duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber* curve    = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
    CGRect oldFrame = _textView.frame;
    CGFloat viewHeight = self.view.bounds.size.height;
    _textView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH, viewHeight - keyboardBounds.size.height);
//    if (IOS_NEWER_OR_EQUAL_TO_7)
//    {
//        _textView.contentSize = _textView.frame.size;
//    }
    _textView.contentSize = _textView.frame.size;
	[UIView commitAnimations];
}
- (void)keyboardWillHide:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
    NSDictionary* info = [notification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (IOS_NEWER_OR_EQUAL_TO_7)
        {
            _textView.contentSize = _textView.frame.size;
        }
        [self.textView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    }];
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
    if (IOS_NEWER_OR_EQUAL_TO_7 && [self numberOfLinesInTextView:textView] > 9)
        return NO;
    else
    {
        if (lineNumbers > 8) return NO;  // ios 6
    }
    if ( (range.location > 160) || (textView.text.length > 160) )  //控制输入文本的长度
        return NO;
    else
        return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    UITextPosition* pos = textView.endOfDocument;
    CGRect currentRect = [textView caretRectForPosition:pos];
    if (currentRect.origin.y > previouRect.origin.y)
    {
        //new line reached, write your code
        lineNumbers++;
    }
    previouRect = currentRect;
}
- (void)sendMsgBtnPressed:(id)sender
{
    [self.textView resignFirstResponder];
    
    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择圈子" options:selectZoneNames handler:^(NSInteger anIndex) {
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
        [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
        [SVProgressHUD showWithStatus:@"消息发送中..."];
        selectIndex = (int)anIndex;
        if (imagePath)
        {
            [self uploadFile:imagePath bucket:QiniuBucketName key:[NSString generateQiNiuFileName]];
        }
        else
        {
            [self publishMessageToServer];
        }
    }];
    [lplv showInView:[UIApplication sharedApplication].keyWindow animated:YES];
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
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 320, 320, 44)];
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
    
    imagePath = [UIImage saveImage:selectedImage withName:@"fuck"];
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
    qiNiuImagePath = [QiniuDomian stringByAppendingString:[ret objectForKey:@"key"]];
    NSLog(@"%s, path=%@", __FUNCTION__, qiNiuImagePath);
    [self publishMessageToServer];
    //    imagePath = path;
}
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    [SVProgressHUD dismiss];
    if ([QiniuAccessKey hasPrefix:@"<Please"])
    {
        NSLog(@"Please replace kAccessKey, kSecretKey and kBucketName with proper values.");
    }
    else
    {
        NSLog(@"upload image file to QiNiu failded!");
        AlertContent(@"同学，网路不给力啊，图片上传失败，稍后再试试.")
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
- (NSUInteger)numberOfLinesInTextView:(UITextView *)textView
{
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSUInteger index, numberOfLines;
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:[textView textContainer]];
    NSRange lineRange;
    
    for (numberOfLines = 0, index = glyphRange.location; index < glyphRange.length; numberOfLines++)
    {
        (void) [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return numberOfLines;
}
- (void)publishMessageToServer
{
    // long areaId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserAreaId];
    long zoneId = [[indexMapZoneName objectForKey:[NSString stringWithFormat:@"%d", selectIndex]] integerValue];
    
    BackGroundImageType backgroudType = ( (imagePath == nil) ? BackGroundWithoutImage : BackGroundWithImage );
    
    MessageModel* message = [[NetWorkConnect sharedInstance] messageCreate:self.textView.text
                                                                   msgType:MessageTypeText
                                                                    areaId:zoneId
                                                                    bgType:backgroudType
                                                                  bgNumber:-1
                                                                     bgUrl:qiNiuImagePath
                                                                       lat:0.0
                                                                       lon:0.0];
    [SVProgressHUD dismiss];
    if (message)
    {
        //通知父视图获取最新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"publishMessageSuccess" object:self userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES ];
    }
}
@end

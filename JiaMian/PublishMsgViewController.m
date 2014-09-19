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
#define kVoteLableTag 9999

@interface PublishMsgViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, QiniuUploadDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIImage* selectedImage;
    QiniuSimpleUploader* qiNiuUpLoader;
    NSString* imagePath;
    NSString* qiNiuImagePath;
    CGRect previouRect;
    NSInteger lineNumbers;
    
    NSInteger selectZoneId;
    
    NSMutableArray* selectZones;
    NSMutableDictionary* indexMapZoneName;
    
    UILabel* huaTiLabel;
    NSMutableArray* votesArr;
}
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* maskImageView;
@property (nonatomic, strong) SAMTextView* inputTextView;
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
    self.inputTextView.layer.borderWidth=0;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //隐藏tableview边框
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.tableHeaderView = [self configureHeaderView];
    [self configurePlaceHolderText:placeHolderText withColor:[UIColor darkGrayColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self configureToolBar];
    votesArr = [NSMutableArray array];
    [votesArr addObject:@"添加一个选项"];
    if (!_isTouPiao)
        self.tableView.scrollEnabled = NO;
    
    previouRect = CGRectZero;
    lineNumbers = 0;
    
    UIBarButtonItem* sendMessageBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(sendMsgBtnPressed:)];
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(handlePopToBack)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    if (IOS_NEWER_OR_EQUAL_TO_7) {
        [sendMessageBarBtn setTintColor:[UIColor whiteColor]];
        [leftBarButton setTintColor:[UIColor whiteColor]];
    }
    self.navigationItem.rightBarButtonItem = sendMessageBarBtn;
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    indexMapZoneName = [NSMutableDictionary dictionary];
    
    NSData* zoneData = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectZones];
    
    selectZones = [NSKeyedUnarchiver unarchiveObjectWithData:zoneData];
    for (id element in selectZones)
    {
        if ([element isMemberOfClass:[AreaModel class]])
        {
            AreaModel* zone = (AreaModel*)element;
            if(zone.type == ZoneTypeIndustry || ZoneTypeSchool == zone.type || ZoneTypeCompany == zone.type)
                [indexMapZoneName setObject:[NSNumber numberWithInt:zone.area_id] forKey:zone.area_name];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.inputTextView resignFirstResponder];
}
- (void)handlePopToBack {
    [UIAlertView showWithTitle:@"提示"
                       message:@"您已编辑了内容，是否放弃?"
             cancelButtonTitle:@"取消"
             otherButtonTitles:@[@"放弃"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (1 ==  buttonIndex)
                              [self.navigationController popViewControllerAnimated:NO];
                      } ];
}
- (void)hiddenKeyBoard:(UISwipeGestureRecognizer*)gesture
{
    [self.inputTextView resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isTouPiao)
        return ( (votesArr.count > 4) ? 4 : votesArr.count);
    else
        return 0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"VoteCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UILabel *voteLabel = (UILabel*)[cell.contentView viewWithTag:kVoteLableTag];
    [voteLabel setText:[votesArr objectAtIndex:indexPath.row]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加投票选项"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alertView.tag = 5678;
    [alertView show];
}
- (UIView*)configureHeaderView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        _inputTextView = [[SAMTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [_inputTextView setFont:[UIFont systemFontOfSize:20]];
        _inputTextView.delegate = self;
        [_inputTextView setScrollEnabled:YES];
        [_inputTextView setUserInteractionEnabled:YES];
        [_inputTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        _maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [_headerView addSubview:_maskImageView];
        [_headerView addSubview:_inputTextView];
        
        _inputTextView.layer.borderWidth = 1.0f;
        _inputTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    return _headerView;
}
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
    NSDictionary* info = [notification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        _toolBar.frame = CGRectMake(0, SCREEN_HEIGHT - 44*2 - 20 - CGRectGetHeight(keyBoardFrame), 320, 44);
        CGRect oldFrame = _inputTextView.frame;
        CGFloat viewHeight = self.view.bounds.size.height;
        
        self.inputTextView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, SCREEN_WIDTH,
                                              viewHeight - CGRectGetHeight(keyBoardFrame) - 44);
        _inputTextView.contentSize = _inputTextView.frame.size;
    }];
}
- (void)keyboardWillHide:(NSNotification*)notification
{
    NSLog(@"call %s", __FUNCTION__);
    NSDictionary* info = [notification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (IOS_NEWER_OR_EQUAL_TO_7)
            _inputTextView.contentSize = _inputTextView.frame.size;
        
        [self.inputTextView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
        [self.toolBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 44*2 - 20, 320, 44)];
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
    if (range.length == 1) //删除
        return YES;
    if (IOS_NEWER_OR_EQUAL_TO_7 && [self numberOfLinesInTextView:textView] > 9)
        return NO;
    else
    {
        if (lineNumbers > 8) return NO;  // ios 6
    }
    
    if ( (range.location > 134) || (textView.text.length > 134) )  //控制输入文本的长度
        return NO;
    else
        return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    UITextPosition* pos = textView.endOfDocument;
    CGRect currentRect = [textView caretRectForPosition:pos];
    if (currentRect.origin.y > previouRect.origin.y) // new line reached, write your code
        lineNumbers++;
    else if(currentRect.origin.y < previouRect.origin.y)
        lineNumbers--;
    else
    {}
    previouRect = currentRect;
}
- (void)sendMsgBtnPressed:(id)sender
{
    NSLog(@"%@", selectZones);
    [UIActionSheet showInView:self.inputTextView
                    withTitle:@"请选择圈子"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:[indexMapZoneName allKeys]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         
                         if (buttonIndex == [selectZones count])
                         {
                             return ;
                         }
                         else
                         {
                             NSString* key = [actionSheet buttonTitleAtIndex:buttonIndex];
                             selectZoneId = [[indexMapZoneName valueForKey:key] integerValue];
                             
                             [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
                             [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
                             [SVProgressHUD showWithStatus:@"消息发送中..."];
                             if (imagePath)
                             {
                                 [self uploadFile:imagePath bucket:QiniuBucketName key:[NSString generateQiNiuFileName]];
                             }
                             else
                             {
                                 [self publishMessageToServer];
                             }
                         }
                     }];
}
- (void)dealloc
{
    [self.inputTextView removeObserver:self forKeyPath:@"contentSize"];
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
        [self.inputTextView  setTextContainerInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    self.inputTextView.attributedPlaceholder = hoderText;
}
- (void)configureToolBar
{
    huaTiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,180,44)];
    [huaTiLabel setFont:[UIFont systemFontOfSize:19]];
    [huaTiLabel setBackgroundColor:[UIColor clearColor]];
    huaTiLabel.textColor=UIColorFromRGB(0x0e77f4);
    
    [self.toolBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 44*2 - 20, 320, 44)];
    _toolBar.items = [NSArray arrayWithObjects:
                      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraBtnPressed:)],
                      
                      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"topic.png"] style:UIBarButtonItemStylePlain target:self action:@selector(huaTiBtnPressed:)],
                      [[UIBarButtonItem alloc] initWithCustomView:huaTiLabel],
                      nil];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolBar sizeToFit];
}
- (void)huaTiBtnPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加标签(限8个字)"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [alertView show];
}
- (void)textFieldDidChange:(UITextField*)textField {
    if (textField.text.length > 16) {
        textField.text = [textField.text substringToIndex:8];
    }
}
- (void)cameraBtnPressed:(id)sender
{
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
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (5678 == alertView.tag)
    {
        if (1 == buttonIndex) {
            [votesArr insertObject:textField.text atIndex:votesArr.count-1];
            [self.tableView reloadData];
            NSInteger row = ( (votesArr.count == 5) ? 3 : votesArr.count-1 );
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    else
    {
        if (1 == buttonIndex) {
            [huaTiLabel setText:textField.text];
        }
    }
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
    
    [self.maskImageView setImage:selectedImage];
    [self.inputTextView setTextColor:UIColorFromRGB(0xffffff)];
    
    [self.inputTextView becomeFirstResponder];
    
    [self.inputTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackalpha"]]];
    [self configurePlaceHolderText:placeHolderText withColor:[UIColor whiteColor]];
    
    imagePath = [UIImage saveImage:selectedImage withName:@"fuck"];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.inputTextView becomeFirstResponder];
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
    if ( _isTouPiao && (votesArr.count <= 1) ) {
        [SVProgressHUD dismiss];
        AlertContent(@"亲，至少要有一个投票项!");
        return;
    }
    NSInteger msgType;
    NSString *votesJsonStr;
    NSString *topicStr = (huaTiLabel.text.length == 0) ? nil : huaTiLabel.text;
    if (_isTouPiao) {
        msgType = 3;
        int votesLen = ( (votesArr.count > 4) ? 4 : votesArr.count - 1 );
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[votesArr subarrayWithRange:NSMakeRange(0, votesLen)]
                                                           options:NSJSONWritingPrettyPrinted error:nil];
        votesJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else
    {
        msgType = 1;
        votesJsonStr = nil;
    }
    BackGroundImageType backgroudType = ( (imagePath == nil) ? BackGroundWithoutImage : BackGroundWithImage );
    MessageModel* message = [[NetWorkConnect sharedInstance] messageCreate:self.inputTextView.text
                                                                   msgType:msgType
                                                                    areaId:selectZoneId
                                                                categoryId:_categoryId  //消息板块id. 默认值:1
                                                                     votes:votesJsonStr
                                                                     topic:topicStr
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

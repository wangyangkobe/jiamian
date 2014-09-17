//
//  SiXinViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-17.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"

#define kHeadImageTag    6000
#define kSiXinLabelTag   6001
#define kMsgTextLabelTag 6002
#define kBgImageViewTag  6003
#define kTimeLabelTag    6004

@interface ChatListViewController () <UITableViewDelegate, UITableViewDataSource, IChatManagerDelegate>
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ChatListViewController

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
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _dataSource = [NSMutableArray array];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshDataSource];
    [self registerNotifications];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public
-(void)refreshDataSource {
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
}

#pragma mark - private
- (NSMutableArray *)loadDataSource {
    NSMutableArray *ret = nil;
    NSArray* result = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *conversations = [NSMutableArray array];
    for (EMConversation* element in result) {
        if (element.latestMessage) {
            [conversations addObject:element];
        }
    }
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2) {
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return (NSComparisonResult)NSOrderedAscending;
                          } else {
                              return (NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}
#pragma mark - registerNotifications
-(void)registerNotifications {
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}
-(void)unregisterNotifications {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - IChatMangerDelegate
-(void)didUnreadMessagesCountChanged {
    [self refreshDataSource];
}
- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error {
    [self refreshDataSource];
}

#pragma mark - TableViewDelegate & TableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"ChatListCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    EMConversation* conversion = (EMConversation*)[_dataSource objectAtIndex:indexPath.row];
    EMMessage* latestMsg = conversion.latestMessage;
    EMTextMessageBody* msgBody = [latestMsg.messageBodies lastObject];
    UILabel* siXinLabel = (UILabel*)[cell.contentView  viewWithTag:kSiXinLabelTag];
    [siXinLabel setText:msgBody.text];
    
    NSDictionary *attribute = [latestMsg.ext objectForKey:@"attribute"];
    UIImageView* headImage = (UIImageView*)[cell.contentView viewWithTag:kHeadImageTag];
    if ([latestMsg.to isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kSelfHuanXinId]]) //收到
        [headImage setImageWithURL:attribute[@"myHeaderUrl"] placeholderImage:nil];
    else
        [headImage setImageWithURL:attribute[@"headerUrl"] placeholderImage:nil];
    
    UIImageView* bgImageView = (UIImageView*)[cell.contentView viewWithTag:kBgImageViewTag];
    int backGroudType = [[attribute objectForKey:@"msgBackgroundType"] integerValue];
    if (2 == backGroudType) {
        NSString* background_url = [attribute objectForKey:@"msgBackgroundUrl"];
        [bgImageView setImageWithURL:[NSURL URLWithString:background_url] placeholderImage:nil];
    } else {
        int bgImageNo = [[attribute objectForKey:@"msgBackgroundNoNew"] integerValue];
        NSString* imageName = [NSString stringWithFormat:@"bg_drawable_%d@2x.jpg", bgImageNo];
        [bgImageView setImage:[UIImage imageNamed:imageName]];
    }
    
    UILabel* msgLabel = (UILabel*)[cell.contentView viewWithTag:kMsgTextLabelTag];
    [msgLabel setText:[attribute objectForKey:@"msgText"]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    NSDictionary* attribute = [conversation.latestMessage.ext objectForKey:@"attribute"];
    ChatViewController* chatController = [self.storyboard instantiateViewControllerWithIdentifier:@"PublishSiXinVCIndentifier"];
    
    chatController.chatter = conversation.chatter;
    chatController.customFlag = [attribute[@"customFlag"] integerValue];
    
    EMMessage* latestMsg = conversation.latestMessage;
    NSLog(@"%@, %@", conversation.chatter, conversation.latestMessage);
    if( [latestMsg.to isEqualToString:[USER_DEFAULT objectForKey:kSelfHuanXinId]] )
    {
        chatController.myHeadImage = attribute[@"headerUrl"];
        chatController.chatterHeadImage = attribute[@"myHeaderUrl"];
    }
    else
    {
        chatController.myHeadImage = attribute[@"myHeaderUrl"];
        chatController.chatterHeadImage = attribute[@"headerUrl"];
    }
    int msgId = [attribute[@"msgId"] integerValue];
    chatController.message = [[NetWorkConnect sharedInstance] messageShowByMsgId:msgId];
    [conversation markMessagesAsRead:YES];
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:NO];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end

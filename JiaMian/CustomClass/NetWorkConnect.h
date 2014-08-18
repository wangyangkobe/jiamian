#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "UserModel.h"
#import "MessageModel.h"
#import "CommentModel.h"
#import "NotificationModel.h"
#import "AreaModel.h"
#import "CommonMarco.h"
#import "TopicModel.h"

@interface NetWorkConnect : NSObject

+(id)sharedInstance;
- (UserModel*)userLogInWithToken:(NSString*)access_token userType:(int)Type userIdentity:(NSString*)Identity;
- (BOOL)userLogOut;
- (UserModel*)userChangeArea:(long)AreaId;
- (UserModel*)userChangeZone:(NSString*)zoneStr;
- (UserModel*)userGetByMsgId:(long)MsgId;
- (UserModel*)userGetByCommentId:(log)CommentId;

//Gender: 1; HeadImg: nil; Description: nil
- (UserModel*)userRegisterWithName:(NSString*)UserName passWord:(NSString*)PassWord userType:(int)Type gender:(int)Gender headImg:(NSString*)HeadImg description:(NSString*)Description;

//UserId: 0; 默认使用当前用户id，若指定此参数，则查询该id对应用户的详情.
- (UserModel*)userShowById:(int)UserId;

//result dict keys: total_count, send_count, remain_count
- (NSDictionary*)userMessageLimit;

//AreaId: 0; SinceId: 0; MaxId: INT_MAX; Count: 20; TrimArea: NO; FilterType: 0
- (NSArray*)messageList:(long)AreaId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count trimArea:(BOOL) TrimArea filterType:(int)FilterType;

- (MessageModel*)messageShowByMsgId:(long)MsgId;
- (MessageModel*)messageLikeByMsgId:(long)MsgId;

//MsgType: 1; AreaId: 1; lat: 0.0; lom: 0.0
- (MessageModel*)messageCreate:(NSString*)Text msgType:(int)MsgType areaId:(long)AreaId bgType:(int)BGType bgNumber:(int)BGNumer bgUrl:(NSString*)BGUrl lat:(double)Lat lon:(double)Long;

//SinceId: 0; MaxId: INT_MAX; Count: 20
- (NSArray*)commentShowByMsgId:(long)MsgId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count;

- (CommentModel*)commentCreate:(long)MsgId text:(NSString*)Text;

//SinceId: 0; MaxId: INT_MAX; Count: 20
- (NSArray*)notificationShow:(long)SinceId maxId:(long)MaxId count:(int)Count;
- (NSInteger)notificationUnreadCount;

//SinceId: 0 MaxId: INT_MAX; Count: 20
- (NSArray*)areaList:(long)SinceId maxId:(long)MaxId count:(int)Count areaType:(int)AreaType filterType:(int)FilterType keyWord:(NSString*)KeyWord;
- (AreaModel*)areaShowByAreaId:(long)AreaID;

//SinceId: 0 MaxId: INT_MAX; Type:0 Count: 3
- (NSArray*)topicList:(long)SinceId maxId:(long)MaxId type:(int)Type count:(int)Count;
- (NSArray*)topicGetMessages:(long)topicId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count;
@end

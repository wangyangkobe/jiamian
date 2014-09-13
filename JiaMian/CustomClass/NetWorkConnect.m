#import "NetWorkConnect.h"
#import "Reachability.h"

#define CustomErrorDomain @"com.jiamiantech"
#define ErrorAlertView     dispatch_async(dispatch_get_main_queue(), ^{ \
[[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"哔哔哔哔，你的网络不太稳定哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
}); \

#define NoNetWorkAlertView dispatch_async(dispatch_get_main_queue(), ^{ \
[[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"您还没有连接网络哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]; \
}); \




@implementation NetWorkConnect

static ASIDownloadCache* myCache;

+(instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        myCache = [[ASIDownloadCache alloc] init];
        
        //设置缓存路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        [myCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"mycache"]];
        [myCache setDefaultCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    });
    return sharedInstance;
}

- (BOOL)checkNetworkStatus
{
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"baidu.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    if (NotReachable == myStatus) {
        NoNetWorkAlertView;
        return NO;
    }else{
        return YES;
    }
}
//////////////////////////////////////////////////////////////////
- (UserModel*)userLogInWithToken:(NSString*)AccessToken userType:(int)Type userIdentity:(NSString *)Identity
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/login", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:AccessToken forKey:@"access_token"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    if (UserTypeRegister == Type)
    {
        [request setPostValue:Identity forKey:@"user_identity"];
    }
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request startSynchronous];
    
    if (200 == request.responseStatusCode)
    {
        UserModel* userInfo = [[UserModel alloc] initWithString:[request responseString] error:nil];
        if (userInfo)
            return userInfo;
        else
        {
            ErrorAlertView; return nil;
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (BOOL)userLogOut
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/logout", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    return YES;
}

//////////////////////////////////////////////////////////////////
- (NSDictionary*)userRegisterWithName:(NSString *)UserName passWord:(NSString *)PassWord userType:(int)Type gender:(int)Gender headImg:(NSString *)HeadImg description:(NSString *)Description
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/register", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:UserName forKey:@"user_name"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    [request setPostValue:[NSNumber numberWithInt:Gender] forKey:@"gender"];
    if (UserTypeRegister == Type)
        [request setPostValue:PassWord forKey:@"user_pwd"];
    if (HeadImg)
        [request setPostValue:HeadImg forKey:@"head_image"];
    if (Description)
        [request setPostValue:Description forKey:@"description"];
    
    [request startSynchronous];
    if ( 200 == [request responseStatusCode] ) {
        UserModel* user = [[UserModel alloc] initWithString:[request responseString] error:nil];
        return @{@"userModel": user};
    }
    else if(500 == [request responseStatusCode])
    {
        NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
        return @{@"error": errorDict[@"err_msg"]};
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}
- (NSDictionary*)userLogInWithUserNameAndPassWord:(NSString*)userName password:(NSString*)passWord {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/login", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:passWord forKey:@"access_token"];
    [request setPostValue:userName forKey:@"user_identity"];
    
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request startSynchronous];
    
    if (200 == request.responseStatusCode)
    {
        UserModel* userInfo = [[UserModel alloc] initWithString:[request responseString] error:nil];
        return @{@"userModel": userInfo};
    }
    else if(500 == request.responseStatusCode)
    {
        NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
        return @{@"error": errorDict[@"err_msg"]};
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}
//////////////////////////////////////////////////////////////////
- (UserModel*)userShowById:(int)UserId
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/show", HOME_PAGE];
    if (0 != UserId)
        requestUrl = [requestUrl stringByAppendingFormat:@"?user_id=%d", UserId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"userShowById: %@", [request responseString]);
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else if( 500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSDictionary*)userMessageLimit
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/messageLimit", HOME_PAGE];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"userMessageLimit: %@", [request responseString]);
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
    else if( 500 == request.responseStatusCode )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)messageList:(long)AreaId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count trimArea:(BOOL) TrimArea filterType:(int)FilterType
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/list?area_id=%ld&count=%d", HOME_PAGE, AreaId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    if ( (FilterType == 0) || (FilterType == 1) )
        requestUrl = [requestUrl stringByAppendingFormat:@"&filter_type=%d", FilterType];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    //NSLog(@"URL = %@, code = %d, %@", requestUrl, request.responseStatusCode, request.responseString);
    
    if (200 == request.responseStatusCode)
    {
        Messages* result = [[Messages alloc] initWithString:[request responseString] error:nil];
        return [result.messages copy];
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageShowByMsgId:(long)MsgId
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/show?message_id=%ld", HOME_PAGE, MsgId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
    {
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageCreate:(NSString *)Text msgType:(int)MsgType areaId:(long)AreaId categoryId:(long)CategoryId votes:(NSString *)Votes topic:(NSString *)Topic bgType:(int)BGType bgNumber:(int)BGNumer bgUrl:(NSString *)BGUrl lat:(double)Lat lon:(double)Long
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setShouldAttemptPersistentConnection:NO];      //彻底禁用持久连接
    [request setShouldContinueWhenAppEntersBackground:YES]; //进入后台继续运行
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithInt:MsgType]  forKey:@"message_type"];
    [request setPostValue:[NSNumber numberWithLong:AreaId]  forKey:@"area_id"];
    [request setPostValue:[NSNumber numberWithInt:BGType]   forKey:@"background_type"];
    [request setPostValue:[NSNumber numberWithInt:BGNumer]  forKey:@"background_no"];
    if (BGUrl)
    {
        [request setPostValue:BGUrl forKey:@"background_url"];
    }
    [request setPostValue:[NSNumber numberWithDouble:Lat]   forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:Long]  forKey:@"long"];
    
    [request setPostValue:[NSNumber numberWithLong:CategoryId] forKey:@"category_id"];
    if (Votes)
        [request setPostValue:Votes forKey:@"votes"];
    if (Topic)
         [request setPostValue:Topic forKey:@"topic"];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode)
    {
        //const char *c = [request.responseString cStringUsingEncoding:NSISOLatin1StringEncoding];
        //NSLog(@"%s, result=%@", __FUNCTION__, [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)commentShowByMsgId:(long)MsgId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/comments/show?message_id=%ld&count=%d", HOME_PAGE, MsgId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startSynchronous];
    
    if (200 == request.responseStatusCode)
    {
        Comments* result = [[Comments alloc] initWithString:[request responseString] error:nil];
        if (result)
            return [result.comments copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}
//////////////////////////////////////////////////////////////////
- (CommentModel*)commentCreate:(long)MsgId text:(NSString*)Text
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/comments/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithLong:MsgId]  forKey:@"message_id"];
    
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[CommentModel alloc] initWithString:[request responseString] error:nil];
    else if( 500 == request.responseStatusCode )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)notificationShow:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/notifications/show?count=%d", HOME_PAGE, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if (200 == request.responseStatusCode)
    {
        NSError* error;
        Notifications* result = [[Notifications alloc] initWithString:[request responseString] error:&error];
        NSLog(@"%s, error = %@", __func__, error);
        if (result)
            return  [result.notifications copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (NSInteger)notificationUnreadCount
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/notifications/unreadCount", HOME_PAGE];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    NSLog(@"%s, result = %@", __FUNCTION__, request.responseString);
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        return [[dict objectForKey:@"unread_count"] integerValue];
    }
    else
        return 0;
}

//////////////////////////////////////////////////////////////////
- (NSArray*)areaList:(long)SinceId maxId:(long)MaxId count:(int)Count areaType:(int)AreaType filterType:(int)FilterType keyWord:(NSString*)KeyWord
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/areas/list?since_id=%ld&area_type=%d", HOME_PAGE, SinceId, AreaType];
    
    if (FilterType == 1 || FilterType == 2)
    {
        requestUrl = [NSString stringWithFormat:@"%@/areas/list?since_id=%ld&filter_type=%d&&area_type=%d&key_word=%@",
                      HOME_PAGE, SinceId, FilterType, AreaType, KeyWord];
        //对url进行编码，因为url含有汉字
        requestUrl = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    //NSLog(@"url = %@, %@", requestUrl, request.responseString);
    if (200 == request.responseStatusCode)
    {
        Areas* result = [[Areas alloc] initWithString:[request responseString] error:nil];
        if(result)
            return [result.areas copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (AreaModel*)areaShowByAreaId:(long)AreaID
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/areas/show?area_id=%ld", HOME_PAGE, AreaID];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[AreaModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageLikeByMsgId:(long)MsgId
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/like", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSNumber numberWithLong:MsgId] forKey:@"message_id"];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}

//////////////////////////////////////////////////////////////////
- (UserModel*)userChangeArea:(long)AreaId
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/area", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSNumber numberWithLong:AreaId] forKey:@"area_id"];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}
//////////////////////////////////////////////////////////////////
- (UserModel*)userChangeZone:(NSString*)zoneStr
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/area", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:zoneStr forKey:@"area_id"];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    }
    else
    {
        ErrorAlertView;
        return nil;
    }
}
//////////////////////////////////////////////////////////////////
- (NSArray*)topicList:(long)SinceId maxId:(long)MaxId type:(int)Type count:(int)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/topics/list?type=%d&count=%d", HOME_PAGE, Type, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    //  NSLog(@"url = %@, %@", requestUrl, request.responseString);
    if (200 == request.responseStatusCode)
    {
        Topics * result = [[Topics alloc] initWithString:[request responseString] error:nil];
        if(result)
            return [result.topics copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}
//////////////////////////////////////////////////////////////////
- (NSArray*)topicGetMessages:(long)topicId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/topics/getMessages?topic_id=%ld&count=%d",
                            HOME_PAGE, topicId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    // NSLog(@"url = %@, %@", requestUrl, request.responseString);
    
    if (200 == request.responseStatusCode) {
        Messages* result = [[Messages alloc] initWithString:[request responseString] error:nil];
        return [result.messages copy];
    } else if(500 == request.responseStatusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    } else {
        ErrorAlertView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (HxUserModel*)userGetByMsgId:(long)MsgId {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/getByMsgId?message_id=%ld", HOME_PAGE, MsgId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[HxUserModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    } else {
        ErrorAlertView;
        return nil;
    }
    
}
//////////////////////////////////////////////////////////////////
- (HxUserModel*)userGetByCommentId:(long)CommentId {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/getByCommentId?comment_id=%ld", HOME_PAGE, CommentId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[HxUserModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == request.responseStatusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return nil;
    } else {
        ErrorAlertView;
        return nil;
    }
}
//////////////////////////////////////////////////////////////////
- (NSArray*)getBannersByCount:(NSInteger)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/navigation/banners?count=%ld", HOME_PAGE, (long)Count];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    //  NSLog(@"%@", request.responseString);
    if (200 == request.responseStatusCode)
    {
        Banners * result = [[Banners alloc] initWithString:[request responseString] error:nil];
        if(result)
            return [result.banners copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}
//////////////////////////////////////////////////////////////////
- (NSArray*)getCategoriesByCount:(NSInteger)Count orderId:(NSInteger)OrderId
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/navigation/categories?count=%ld",
                            HOME_PAGE, (long)Count];
    if (OrderId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&order_id=%ld", (long)OrderId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    // NSLog(@"%@", request.responseString);
    if (200 == request.responseStatusCode)
    {
        Categories * result = [[Categories alloc] initWithString:[request responseString] error:nil];
        if(result)
            return [result.categories copy];
        else
        {
            ErrorAlertView;
            return [NSArray array];
        }
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}

//////////////////////////////////////////////////////////////////
- (NSArray*)categoryMsgWithType:(int)type categoryId:(long)CategoryId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/category?type=%d&category_id=%ld&count=%d",
                            HOME_PAGE, type, CategoryId, Count];
    if (SinceId != 0)
        requestUrl = [requestUrl stringByAppendingFormat:@"&since_id=%ld", SinceId];
    if (MaxId != INT_MAX)
        requestUrl = [requestUrl stringByAppendingFormat:@"&max_id=%ld", MaxId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
  //  NSLog(@"URL = %@, code = %d, %@", requestUrl, request.responseStatusCode, request.responseString);
    
    if (200 == request.responseStatusCode)
    {
        NSError* error;
        Messages* result = [[Messages alloc] initWithString:[request responseString] error:&error];
        NSLog(@"error = %@", error);
        return [NSArray arrayWithArray:result.messages];
    }
    else if(500 == request.responseStatusCode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* errorDict = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            AlertContent(errorDict[@"err_msg"]);
        });
        return [NSArray array];
    }
    else
    {
        ErrorAlertView;
        return [NSArray array];
    }
}
//////////////////////////////////////////////////////////////////
- (NSDictionary*)reportMessageByMsgId:(long)MsgId {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/reportmessage",  HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSNumber numberWithLong:MsgId] forKey:@"message_id"];
    [request startSynchronous];
    NSLog(@"%@, %@", requestUrl, request.responseString);
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
    else
        return nil;
}
//////////////////////////////////////////////////////////////////
- (NSDictionary*)reportUserByMsgId:(long)MsgId {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/reportuser",  HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSNumber numberWithLong:MsgId] forKey:@"message_id"];
    [request startSynchronous];
    NSLog(@"%@, %@", requestUrl, request.responseString);
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
    else
        return nil;
}
@end

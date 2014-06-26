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
- (UserModel*)userRegisterWithName:(NSString *)UserName passWord:(NSString *)PassWord userType:(int)Type gender:(int)Gender headImg:(NSString *)HeadImg description:(NSString *)Description
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
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else if(500 == [request responseStatusCode])
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
- (MessageModel*)messageCreate:(NSString*)Text msgType:(int)MsgType areaId:(long)AreaId bgType:(int)BGType bgNumber:(int)BGNumer bgUrl:(NSString *)BGUrl lat:(double)Lat lon:(double)Long
{
    if (NO == [self checkNetworkStatus])
        return nil;
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithInt:MsgType]  forKey:@"message_type"];
    [request setPostValue:[NSNumber numberWithLong:AreaId]   forKey:@"area_id"];
    [request setPostValue:[NSNumber numberWithInt:BGType]   forKey:@"background_type"];
    [request setPostValue:[NSNumber numberWithInt:BGNumer]   forKey:@"background_no"];
    if (BGUrl)
    {
        [request setPostValue:BGUrl forKey:@"background_url"];
    }
    [request setPostValue:[NSNumber numberWithDouble:Lat]   forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:Long]  forKey:@"long"];
    
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
        Notifications* result = [[Notifications alloc] initWithString:[request responseString] error:nil];
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
- (NSArray*)areaList:(long)SinceId maxId:(long)MaxId count:(int)Count FilterType:(int)filterType keyWord:(NSString*)KeyWord
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/areas/list?since_id=%ld", HOME_PAGE, SinceId];
    
    if (filterType == 1 || filterType == 2)
    {
        requestUrl = [NSString stringWithFormat:@"%@/areas/list?since_id=%ld&filter_type=%d&key_word=%@",
                      HOME_PAGE, SinceId, filterType, KeyWord];
        //对url进行编码，因为url含有汉字
        requestUrl = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSLog(@"url = %@, %@", requestUrl, request.responseString);
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
@end

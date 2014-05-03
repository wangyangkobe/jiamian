#import "NetWorkConnect.h"
#define CustomErrorDomain @"com.jiamiantech"

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

//////////////////////////////////////////////////////////////////
- (UserModel*)userLogInWithToken:(NSString*)AccessToken userIdentify:(NSString*)Identity userType:(int)Type error:(NSError**)Error
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/login", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:AccessToken forKey:@"access_token"];
    [request setPostValue:Identity forKey:@"user_identity"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    
    [request startSynchronous];
    
    NSLog(@"%@ responseString=%d", requestUrl, request.responseStatusCode);
    if ( [request responseStatusCode] != 200 )
    {
        //{"err_code":"10001","err_msg":"Test Login Error"}
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: nil];
        *Error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:userInfo];
        return nil;
    }
    else
    {
        NSError* error;
        UserModel* userInfo = [[UserModel alloc] initWithString:[request responseString] error:&error];
        NSLog(@"%s, error = %@", __FUNCTION__, error.description);
        return userInfo;
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
- (UserModel*)userRegisterWithName:(NSString*)UserName userType:(int)Type gender:(int)Gender headImg:(NSString*)HeadImg description:(NSString*)Description
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/users/register", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:UserName forKey:@"user_name"];
    [request setPostValue:[NSNumber numberWithInt:Type] forKey:@"user_type"];
    [request setPostValue:[NSNumber numberWithInt:Gender] forKey:@"gender"];
    if (HeadImg)
        [request setPostValue:HeadImg forKey:@"head_image"];
    if (Description)
        [request setPostValue:Description forKey:@"description"];
    
    [request startSynchronous];
    if ( 200 == [request responseStatusCode] )
        return [[UserModel alloc] initWithString:[request responseString] error:nil];
    else
        return nil;
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
    else
        return nil;
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
    else
        return nil;
}

//////////////////////////////////////////////////////////////////
- (NSArray*)messageList:(int)AreaId sinceId:(long)SinceId maxId:(long)MaxId count:(int)Count trimArea:(BOOL) TrimArea filterType:(int)FilterType
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/list?area_id=%d&count=%d", HOME_PAGE, AreaId, Count];
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
    
    NSLog(@"URL = %@, code = %d, %@", requestUrl, request.responseStatusCode, request.responseString);
    if (200 == [request responseStatusCode])
    {
        NSError* error;
        Messages* result = [[Messages alloc] initWithString:[request responseString] error:&error];
        if (result) {
            return [result.messages copy];
        }else{
            NSLog(@"error = %@", [error description]);
            return [NSArray array];
        }
    }
    else
        return [NSArray array];
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
    else
        return nil;
}

//////////////////////////////////////////////////////////////////
- (MessageModel*)messageCreate:(NSString*)Text msgType:(int)MsgType areaId:(int)AreaId lat:(double)Lat lon:(double)Long
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/messages/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithInt:MsgType]  forKey:@"message_type"];
    [request setPostValue:[NSNumber numberWithInt:AreaId]   forKey:@"area_id"];
    [request setPostValue:[NSNumber numberWithDouble:Lat]   forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:Long]  forKey:@"long"];
    
    [request startSynchronous];
    NSLog(@"%s, result=%@", __FUNCTION__, [request responseString]);
    if ( 200 == [request responseStatusCode] )
        return [[MessageModel alloc] initWithString:[request responseString] error:nil];
    else
        return nil;
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
    
    NSMutableArray* result = [NSMutableArray array];
    NSLog(@"url = %@, comment = %@", requestUrl, request.responseString);
    if ( 200 == [request responseStatusCode] )
    {
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:[request responseData]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        for (id entry in jsonArray)
        {
            CommentModel* comment = [[CommentModel alloc] initWithDictionary:entry error:nil];
            if (comment)
                [result addObject:comment];
        }
    }
    return result;
}
//////////////////////////////////////////////////////////////////
- (CommentModel*)commentCreate:(long)MsgId text:(NSString*)Text
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/comments/create", HOME_PAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:Text forKey:@"text"];
    [request setPostValue:[NSNumber numberWithLong:MsgId]  forKey:@"message_id"];
    
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
        return [[CommentModel alloc] initWithString:[request responseString] error:nil];
    else
        return nil;
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
    
    NSMutableArray* result = [NSMutableArray array];
    if ( 200 == [request responseStatusCode] )
    {
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:nil];
        for (id entry in jsonArray)
        {
            NotificationModel* notification = [[NotificationModel alloc] initWithDictionary:entry error:nil];
            if (notification)
                [result addObject:notification];
        }
        return result;
    }
    else
        return nil;
}

//////////////////////////////////////////////////////////////////
- (int)notificationUnreadCount
{
    NSString* requestUrl = [NSString stringWithFormat:@"%@/notifications/unreadCount", HOME_PAGE];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setDownloadCache:myCache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    if ( 200 == [request responseStatusCode] )
    {
        NSData *jsonData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        return [[dict objectForKey:@"unread_count"] integerValue];
    }
    else
        return 0;
}
@end
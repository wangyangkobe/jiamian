//
//  NSString+Extenions.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "NSString+Extenions.h"
#import "CommonMarco.h"
#define kSystemVersion ([[UIDevice currentDevice] systemVersion].intValue)
@implementation NSString (Extenions)

+ (CGFloat)textHeight:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size
{
    // CGSize textSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    // return textSize.height;
    return [text sizeWithFont:font constrainedToSize:size].height;
}
+ (NSString*)convertTimeFormat:(NSString*)timeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *nowDate = [NSDate date];
    NSDate *endDate = [dateFormatter dateFromString:timeStr];
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:endDate toDate:nowDate options:0];
    if (comps.month > 0)
        return [NSString stringWithFormat:@"%d月前", (int)comps.month];
    else if(comps.day > 0)
        return [NSString stringWithFormat:@"%d天前", (int)comps.day];
    else if(comps.hour >0 )
        return [NSString stringWithFormat:@"%d小时前", (int)comps.hour];
    else if(comps.minute)
        return [NSString stringWithFormat:@"%d分钟前", (int)comps.minute];
    else
        return @"刚刚";
}

- (CGSize)sizeWithFont:(UIFont *)font
{
    return [self sizeWithFont:font constrainedToSize:(CGSize)
            {MAXFLOAT, MAXFLOAT}];
}

- (CGSize)sizeWithFontSize:(float)fSize constrainedToSize:(CGSize)cSize
{
    UIFont *font = [UIFont systemFontOfSize:fSize];
    return [self sizeWithFont:font constrainedToSize:cSize];
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)cSize
{
    if (kSystemVersion < 7)
    {
        CGSize size = [self sizeWithFont:font constrainedToSize:cSize
                           lineBreakMode:NSLineBreakByWordWrapping];
        return size;
    }
    else
    {
        NSDictionary *stringAttributes = @{NSFontAttributeName:font};
        CGRect rect = [self boundingRectWithSize:cSize
                                         options:NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading
                                      attributes:stringAttributes
                                         context:nil];
        
        return rect.size;
    }
}

+ (NSString*)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *res = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [res appendFormat:@"%02x",result[i]];
    }
    return res;
}
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}
+ (NSString*)generateQiNiuFileName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    return [NSString stringWithFormat:@"%@%@", [formatter stringFromDate:[NSDate date]],
            [NSString randomAlphanumericStringWithLength:10]];
}
+ (UIColor*)hexStringToColor:(NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"0x"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end

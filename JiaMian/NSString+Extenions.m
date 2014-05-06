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
        return [NSString stringWithFormat:@"%d月前", comps.month];
    else if(comps.day > 0)
        return [NSString stringWithFormat:@"%d天前", comps.day];
    else if(comps.hour >0 )
        return [NSString stringWithFormat:@"%d小时前", comps.hour];
    else if(comps.minute)
        return [NSString stringWithFormat:@"%d分钟前", comps.minute];
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
@end

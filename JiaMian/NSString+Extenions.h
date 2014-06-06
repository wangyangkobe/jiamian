//
//  NSString+Extenions.h
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extenions)
+ (CGFloat)textHeight:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size;
+ (NSString*)convertTimeFormat:(NSString*)timeStr;
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFontSize:(float)fSize constrainedToSize:(CGSize)cSize;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)cSize;
+ (NSString*)md5HexDigest:(NSString*)inputStr;
@end

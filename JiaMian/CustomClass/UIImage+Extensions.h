//
//  UIImage+Extensions.h
//  
//
//  Created by wy on 13-12-18.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
+ (NSString*)saveImage:(UIImage *)image withName:(NSString *)name;

@end

//
//  UIImage+Extensions.m
//
//
//  Created by wy on 13-12-18.
//
//

#import "UIImage+Extensions.h"

@implementation UIImage (Extensions)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(NSString*)saveImage:(UIImage *)image withName:(NSString *)name
{
    //grab the data from our image
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (data == nil)
    {
        data = UIImagePNGRepresentation(image);
    }
    //get a path to the documents Directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Add out name to the end of the path with .JPG
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", name]];
    //Save the file, over write existing if exists.
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    
    //计算压缩后的文件大小
    NSDictionary *sourceAttributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
    NSNumber *sourceFileSize = [sourceAttributes objectForKey:NSFileSize];
    long long fileSize = [sourceFileSize longLongValue];
    NSLog(@"Filesize = %lld", fileSize / 1024);
    
    return fullPath;
}

@end

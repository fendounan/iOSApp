//
//  SWTImageUtils.m
//  SuperList
//
//  Created by SWT on 2017/11/23.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTImageUtils.h"

@implementation SWTImageUtils

+ (UIImage *)reSizeImage:(UIImage *)originalImage toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

+ (UIImage *)captureImage:(UIImage *)captureImage captureSize:(CGSize)captureSize path:(UIBezierPath *)path{
    UIGraphicsBeginImageContextWithOptions(captureSize, NO, 0);
    [path addClip];
    [captureImage drawAtPoint:CGPointMake(0, 0)];
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipImage;
    
}

/**
 * 将UIColor变换为UIImage
 *
 **/
+ (UIImage *)createImageWithColor:(UIColor *)color rectMake:(CGRect)rect
{
    //设置长宽
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}
@end

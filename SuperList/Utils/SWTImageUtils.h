//
//  SWTImageUtils.h
//  SuperList
//
//  Created by SWT on 2017/11/23.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SWTImageUtils : NSObject

/**
 改变图片的大小

 @param originalImage 需要改变尺寸的图片
 @param reSize 需要改变的尺寸
 @return 改变后的图片
 */
+ (UIImage *)reSizeImage:(UIImage *)originalImage toSize:(CGSize)reSize;

/**
 根据贝塞尔曲线裁切图片

 @param captureImage 需要裁切的图片
 @param path 裁切的形状
 @return 裁切后的图片
 */
+ (UIImage *)captureImage:(UIImage *)captureImage captureSize:(CGSize)captureSize path:(UIBezierPath *)path;

/**
 根据颜色值生成纯色图片
 
 @param color 颜色
 @param CGRect 大小
 @return 裁切后的图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color rectMake:(CGRect)rect;
@end

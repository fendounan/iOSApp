//
//  NSString+Size.m
//  ERP
//
//  Created by SWT on 2017/5/19.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

-(CGSize)heightWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font
{
    CGRect rect =[string boundingRectWithSize:CGSizeMake(width, 10000) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size;
}

- (CGFloat)widthWithFont:(UIFont *)font{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.width;
}
@end

//
//  NSString+Size.h
//  ERP
//
//  Created by SWT on 2017/5/19.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

-(CGSize)heightWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font;
- (CGFloat)widthWithFont:(UIFont *)font;
@end

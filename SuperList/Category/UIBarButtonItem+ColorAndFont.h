//
//  UIBarButtonItem+ColorAndFont.h
//  SDL
//
//  Created by SWT on 2017/9/11.
//  Copyright © 2017年 胡定锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ColorAndFont)

+ (instancetype)barButtomItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action textColor:(UIColor *)textColor font:(UIFont *)font;

@end

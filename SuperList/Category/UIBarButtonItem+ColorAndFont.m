//
//  UIBarButtonItem+ColorAndFont.m
//  SDL
//
//  Created by SWT on 2017/9/11.
//  Copyright © 2017年 胡定锋. All rights reserved.
//

#import "UIBarButtonItem+ColorAndFont.h"

@implementation UIBarButtonItem (ColorAndFont)

+ (instancetype)barButtomItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action textColor:(UIColor *)textColor font:(UIFont *)font{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action];
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,textColor, NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    return barButtonItem;
}

@end

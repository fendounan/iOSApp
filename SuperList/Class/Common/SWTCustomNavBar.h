//
//  SWTCustomNavBar.h
//  SuperList
//
//  Created by SWT on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWTCustomNavBar : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *hairlineColor;
/** 底部分割线是否隐藏 YES:隐藏  NO:不隐藏 */
@property (nonatomic, assign) BOOL hairHidden;

- (void)setCustomNavBarBackgroundColor:(UIColor *)customNavBackgroundColor;
- (void)setCustomNavBarBackgroundImage:(UIImage *)customNavBackgroundImage;
- (void)leftBarWithImage:(UIImage *)barImage target:(id)target selector:(SEL)selector;
- (void)rightBarWithImage:(UIImage *)barImage target:(id)target selector:(SEL)selector;

@end

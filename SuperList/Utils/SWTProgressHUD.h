//
//  SWTProgressHUD.h
//  SuperList
//
//  Created by SWT on 2017/11/14.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SWTProgressHUD : NSObject

/**
 显示HUD

 @param view view为nil时添加到window上面
 @param text 显示的文字
 */
+ (instancetype)showHUDAddedTo:(UIView *)view text:(NSString *)text;
- (void)showHUDAddedTo:(UIView *)view text:(NSString *)text;

+ (instancetype)showCompleteHUDAddedTo:(UIView *)view;
- (void)showCompleteHUDAddedTo:(UIView *)view;
- (void)setMessage:(NSString *)message;

/**
 吐司：默认二秒消失

 @param view view为nil时添加到window上面
 @param message 显示的文字
 */
+ (void)toastMessageAddedTo:(UIView *)view message:(NSString *)message;

+ (void)toastMessageAddedTo:(UIView *)view message:(NSString *)message hideWithSeconds:(NSTimeInterval)sencods;

- (void)hideAnimated:(BOOL)animated;

@end

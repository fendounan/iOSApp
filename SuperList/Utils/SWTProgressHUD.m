//
//  SWTProgressHUD.m
//  SuperList
//
//  Created by SWT on 2017/11/14.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTProgressHUD.h"
#import "MBProgressHUD.h"

@interface SWTProgressHUD ()
@property (nonatomic, strong) MBProgressHUD *hud;
@end

static MBProgressHUD *HUD;

@implementation SWTProgressHUD

+ (instancetype)showHUDAddedTo:(UIView *)view text:(NSString *)text{
    SWTProgressHUD *hud = [[self alloc] init];
    [hud showHUDAddedTo:view text:text];
    return hud;
}

- (void)showHUDAddedTo:(UIView *)view text:(NSString *)text{
    UIView *superView;
    if (view) {
        superView = view;
    } else {
        superView = [UIApplication sharedApplication].keyWindow;
    }
    if (_hud) {
        [_hud hideAnimated:NO];  
    }
    
    if (HUD) {
        [HUD removeFromSuperview];
    }
    _hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    
    _hud.label.font = [UIFont systemFontOfSize:15];
    
    if (text) {
        _hud.label.text = text;
    } else {
        _hud.label.text = nil;
    }
}

- (void)setMessage:(NSString *)message
{
    if (_hud) {
        _hud.label.text = message;
         [_hud hideAnimated:NO];  
    }
}

+ (instancetype)showCompleteHUDAddedTo:(UIView *)view{
    SWTProgressHUD *hud = [[SWTProgressHUD alloc] init];
    [hud showCompleteHUDAddedTo:view];
    return hud;
}

- (void)showCompleteHUDAddedTo:(UIView *)view{
    UIView *superView;
    if (view) {
        superView = view;
    } else {
        superView = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.label.text = @"完成";
    [hud hideAnimated:YES afterDelay:2.5];
}

+ (void)toastMessageAddedTo:(UIView *)view message:(NSString *)message{
    [self toastMessageAddedTo:view message:message hideWithSeconds:2];
}

+ (void)toastMessageAddedTo:(UIView *)view message:(NSString *)message hideWithSeconds:(NSTimeInterval)sencods{
    if (!message || !message.length) {
        return;
    } 
    
    UIView *superView;
    if (view) {
        superView = view;
    } else {
        superView = [UIApplication sharedApplication].keyWindow;
    }
    if (HUD) {
        [HUD hideAnimated:NO];
        [HUD removeFromSuperview];
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    HUD.detailsLabel.font = HUD.label.font;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabel.text = message;
    HUD.detailsLabel.textColor = HUD.label.textColor;
    HUD.userInteractionEnabled = NO;
    [HUD hideAnimated:YES afterDelay:sencods];
}

- (void)hideAnimated:(BOOL)animated{
    if (_hud) {
        [_hud hideAnimated:animated];
        _hud = nil;
    }
}

@end

//
//  PayPasswordTF.m
//  SuperList
//
//  Created by SWT on 2017/7/3.
//  Copyright © 2017年 sanweitong. All rights reserved.
//

#import "PayPasswordTF.h"

@implementation PayPasswordTF

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end

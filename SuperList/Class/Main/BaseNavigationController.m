//
//  BaseNavigationController.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "BaseNavigationController.h"
#import "UIColor+StringToColor.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor hexStringToColor:mColor_TopTarBg];
    
    // 设置title的样式
    NSMutableDictionary *titleDic = [NSMutableDictionary dictionary];
    titleDic[NSForegroundColorAttributeName] = [UIColor hexStringToColor:@"#ffffff"];
    titleDic[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    self.navigationBar.titleTextAttributes = titleDic;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    UIViewController *vc = self.topViewController;
    return [vc preferredStatusBarStyle];
}

@end

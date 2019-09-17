//
//  BaseTabBarController.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "HomePageVC.h"
#import "InformationVC.h"
#import "ExtensionVC.h"
#import "MineVC.h"
#import "UIColor+StringToColor.h"
#import "LoginVC.h"

@interface BaseTabBarController ()<UITabBarControllerDelegate>

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    // 首页
    HomePageVC *homePageVC = [[HomePageVC alloc] init];
    BaseNavigationController *homeNavController = [[BaseNavigationController alloc] initWithRootViewController:homePageVC];
    
    //信息
    InformationVC *informationVC = [[InformationVC alloc] init];
    BaseNavigationController *informationNavController = [[BaseNavigationController alloc] initWithRootViewController:informationVC];
    
    // 推广
    ExtensionVC *exteensionVC = [[ExtensionVC alloc] init];
    BaseNavigationController *exteensionNavController = [[BaseNavigationController alloc] initWithRootViewController:exteensionVC];
    
    // 我的
    MineVC *mineVC = [[MineVC alloc] init];
    BaseNavigationController *mineNavController = [[BaseNavigationController alloc] initWithRootViewController:mineVC];
    
    self.viewControllers = @[homeNavController,informationNavController,exteensionNavController,mineNavController];
    
    NSArray *titleArr = @[@"首页",@"信息",@"推广",@"我的"];
    NSArray *normalImageArr = @[@"b_page_1_1",@"b_page_2_1",@"tabbar_client",@"tabbar_mine"];
    NSArray *selectImageArr = @[@"b_page_1_2",@"b_page_2_2",@"tabbar_client_selected",@"tabbar_mine_selected"];
    
//    self.tabBar.tintColor = [UIColor hexStringToColor:@"#f33632"];
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.title = titleArr[idx];
        item.tag = idx;
        
        UIImage *normalImage = [[UIImage imageNamed:normalImageArr[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectImage = [[UIImage imageNamed:selectImageArr[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image = normalImage;
        item.selectedImage = selectImage;
        
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor hexStringToColor:@"#999999"]} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor hexStringToColor:mColor_TopTarBg]} forState:UIControlStateSelected];
        
    }];
    
}


//根据token 判断是否弹出login页面
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    
    // 存储点击的index
    [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:@"tabBarSelectedIndex"];
    
        
    return YES;
    
}

@end

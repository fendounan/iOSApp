//
//  BaseSubTabBarController.h
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestInstance.h"
#import "SYBLocalDefine.h"
#import "UIColor+StringToColor.h"
#import "SWTReachability.h"

@interface BaseSubTabBarController : UIViewController

/** 导航栏下面的黑线，使用时在viewWillAppear里面隐藏，在viewDidDisappear里面不隐藏 */
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

@property (nonatomic, strong) UIView *noNetworkView;
@property (nonatomic, strong) UIView *errorDataView;

@property (nonatomic,assign)BOOL isLoadedData;

/**
 网络不可用，网络切换时实时调用
 */
- (void)networkNotReachability;

/**
 网络可用，网络切换时实时调用
 */
- (void)networkReachability;


/**
 获取数据失败时的重新加载数据
 */
- (void)reRequestData;


/**
 将数据错误视图从父视图中移除
 */
- (void)dismissErrorDataView;

/**
 将网络错误视图从父视图中移除
 */
- (void)dismissNoNetworkView;
/**
 暂无数据
 */
- (UIView *)noDataView;
@end

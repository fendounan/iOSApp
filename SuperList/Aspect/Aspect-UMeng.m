//
//  Aspect-UMeng.m
//  SuperList
//
//  Created by SWT on 2017/11/22.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <UMAnalytics/MobClick.h>
#import <UMCommon/UMCommon.h>
#import "UMShare.h"
#import <XAspect/XAspect.h>

#define AtAspect UMeng
#define AtAspectOfClass AppDelegate


@classPatchField(AppDelegate)

AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions) {
    
    [UMConfigure setLogEnabled:NO];
    [UMConfigure initWithAppkey:@"5b4c2bff8f4a9d521e000059" channel:@"App Store"];

    // 统计组件配置
    [MobClick setScenarioType:E_UM_NORMAL];

    // 友盟分享调试日志
    [[UMSocialManager defaultManager] openLog:NO];
    // 设置友盟appKey
//    [[UMSocialManager defaultManager] setUmSocialAppkey:@"5b4c2bff8f4a9d521e000059"];
    [MobClick setCrashReportEnabled:YES];   // 关闭Crash收集
    //关闭强制验证https
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;

    [self confitUShareSettings];
    
    return XAMessageForward(application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);
}

- (void)confitUShareSettings{
    // 微信
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxfbf1393a9629bafa" appSecret:@"5450085e708a616fd91fd7c684302864" redirectURL:@"http://www.yajiee.com/"];
    
    // QQ
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1107047472" appSecret:nil redirectURL:@"http://www.yajiee.com/"];
    
    // 新浪
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"2480019237"  appSecret:@"6ad4f803aa1c207a5a688580d8d51447" redirectURL:@"http://www.yajiee.com/"];
    
}

@end

#undef AtAspectOfClass
#undef AtAspect


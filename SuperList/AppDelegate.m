//
//  AppDelegate.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "AppDelegate.h"
#import "NNGuideViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SWTProgressHUD.h"
#import "SWTUtils.h"
#import "SWTReachability.h"
#import "MD5Util.h"
#import "RequestInstance.h"
#import "UMSocialManager.h"
#import "JPUSHService.h"
#import "BaseNavigationController.h"
#import "SWTWebViewController.h"
#import "SYBVersionAlertView.h"
#import "SDWebImageDownloader.h"
#import "SYBLocalDefine.h"
#import "PPGetAddressBook.h"
#import "AMapServices.h"

// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UIAlertViewDelegate,JPUSHRegisterDelegate,SYBVersionAlertViewDelegate>{
    NSDictionary * myuserInfo;
}

@property (nonatomic,strong) NSDictionary *notificationInfos;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [SWTReachability shareInstance];
    /**
     * 高德地图
     */
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = @"8ef60419ae4de7512dfa667a56975078";
    
    _mainTabbarVC = [[BaseTabBarController alloc] init];
    self.window.rootViewController = _mainTabbarVC;

    
    [self.window makeKeyAndVisible];
    
    // 推送
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    [JPUSHService setupWithOption:launchOptions appKey:@"12b43be5a2a16cb147878b36"
                          channel:@"App Store"
                 apsForProduction:JPushApsProduction
            advertisingIdentifier:nil];

    // 检查版本更新
    [self checkVersionUpgrades:YES];
    //请求用户获取通讯录权限
    //由于进入启动页请求的权限过多，暂时注释，看需求
//    [PPGetAddressBook requestAddressBookAuthorization];
    return YES;
}

// 检查版本更新
- (void)checkVersionUpgrades:(BOOL)isCheckUp{
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Upgrade") parameters:nil usableStatus:^(NSDictionary *dic) {
        
        NSDictionary *dataDic = dic[@"data"];
        NSString *strTrips = dataDic[@"Trips"];
        NSArray *arrTrips = [strTrips componentsSeparatedByString:@"|"];
//        NSArray *arrTrips = [strTrips componentsJoinedByString:@"|"];
        if ([[dataDic objectForKey:@"isforce"] intValue] == 1) { // 强制更新
            
            [[[SYBVersionAlertView alloc] initWithContent:arrTrips delegate:self forceUpdating:YES] show];
            
        } else { // 非强制更新
            
            [[[SYBVersionAlertView alloc] initWithContent:arrTrips delegate:self forceUpdating:NO] show];
        }
        
    } unusableStatus:nil error:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    return result;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    application.applicationIconBadgeNumber = 0;
    
    //注册 applicationIconBadgeNumber
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
        {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
        }
}

- (void)showNotificationAlertWithUserInfo:(NSDictionary *)userInfo{
    UIAlertView *alert = [[UIAlertView alloc]init];
    
    alert.tag = 520;
    
    alert.delegate = self;
    
    if ([[userInfo objectForKey:@"msg_type"] intValue] == 1) {
        
        [alert setTitle:@"消息"];
        
    }
    [alert setMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"查看"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 520 && buttonIndex == 1){
        
        [self presentViewControllerWithUserInfo:self.notificationInfos];
        
    }
    myuserInfo = nil;
    self.notificationInfos = nil;
}

- (void)presentViewControllerWithUserInfo:(NSDictionary *)userInfo{
    
    if ([userInfo[@"msg_type"] intValue] == 1) {
        
        [self processNoticeNotification:self.window.rootViewController];
        
    }
    
}

#pragma handle and transfer

// 跳转到网页
- (void)processNoticeNotification:(UIViewController *)vc {
    
    if( [self.notificationInfos.allKeys containsObject:@"msg_url"]) {
        
        SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:webViewVC];
        webViewVC.titleString = [self.notificationInfos objectForKey:@"msg_title"];
        webViewVC.urlString = self.notificationInfos[@"msg_url"];
        webViewVC.isPresent = YES;
        [vc presentViewController:nav animated:NO completion:nil];
        self.notificationInfos = nil;
    }
}

#pragma mark - JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
    
    self.notificationInfos = userInfo;
    [self showNotificationAlertWithUserInfo:userInfo];
}

#pragma mark - SYBVersionAlertViewDelegate 更新提示

- (void)versionUpdate:(SYBVersionAlertView *)alertView{
    
    if (alertView.isForceUpdating) { // 强制更新
        
        [SWTUtils logout];
        
        [[UIApplication sharedApplication] openURL:[SWTUtils appstoreURL]];
        exit(0);
        
    } else { // 非强制更新
        
        [[UIApplication sharedApplication] openURL:[SWTUtils appstoreURL]];
        [alertView hide];
        
    }
    
}

@end

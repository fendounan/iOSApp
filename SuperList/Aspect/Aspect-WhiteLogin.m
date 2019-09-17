//
//  Aspect-WhiteLogin.m
//  SuperList
//
//  Created by XuYan on 2018/7/4.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XAspect/XAspect.h>
#import "AppDelegate.h"
#import "RequestInstance.h"
#import "SWTUtils.h"
#import "UserEnertyModel.h"

#define AtAspect WhiteLogin
#define AtAspectOfClass AppDelegate

@classPatchField(AppDelegate)

AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions) {
    // 生成唯一标识
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"machineCode"] == nil) {
        NSString *machine_code = [SWTUtils getUniqueStrByUUID];
        NSLog(@"machine_code------%@",machine_code);
        [[NSUserDefaults standardUserDefaults] setObject:machine_code forKey:@"machineCode"];
    }
    //如果获取成功，保存整个登录对象
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    NSString *strUrl = @"api/Customer/WhiteLogin";
    NSString *mobile = [userDefaults objectForKey:@"Mobile"];
    if(mobile&&![mobile isEqualToString:@""]){
        paramesDic[@"mobile"] = [userDefaults objectForKey:@"Mobile"];
        paramesDic[@"password"] = [userDefaults objectForKey:@"Password"];
        strUrl = @"api/Customer/LoginByMobile";
    }
    
    
    [[RequestInstance shareInstance] POST:GETAPIURL(strUrl) parameters:paramesDic usableStatus:^(NSDictionary *dict) {
        
        NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithDictionary:dict[@"data"]];
        [dictData setValue:[userDefaults objectForKey:@"Password"] forKey:@"Password"];
        [userDefaults setObject:dictData forKey:@"user"];
        
        UserEnertyModel *userModel = [[UserEnertyModel alloc]initWithDictionary:dictData error:nil];
        userModel.Password = [userDefaults objectForKey:@"Password"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userModel.DevId forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.State forKey:@"State"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.StateString forKey:@"StateString"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.ActiveCode forKey:@"ActiveCode"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Mobile forKey:@"Mobile"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Password forKey:@"Password"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Wx forKey:@"Wx"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.QQ forKey:@"QQ"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Nickname forKey:@"Nickname"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.registtime forKey:@"registtime"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.stoptime forKey:@"stoptime"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userModel.CardId forKey:@"CardId"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Type forKey:@"Type"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.ShowOrigin forKey:@"ShowOrigin"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.ShowTele forKey:@"ShowTele"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Rows forKey:@"Rows"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userModel.Id forKey:@"Id"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.QueryCnt forKey:@"QueryCnt"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.AddCnt forKey:@"AddCnt"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.ShareCnt forKey:@"ShareCnt"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.IsAuth forKey:@"IsAuth"];
        [[NSUserDefaults standardUserDefaults] setObject:userModel.imob forKey:@"imob"];
        
        
    } unusableStatus:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
    return XAMessageForward(application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);
}
@end

#undef AtAspectOfClass
#undef AtAspect

//
//  RequestInstance.m
//  SanYiBao
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "RequestInstance.h"
#import "AFNetworking.h"
#import "SYBLocalDefine.h"
#import "MD5Util.h"
#import "AppDelegate.h"
#import "SWTUtils.h"
#import "LoginVC.h"
#import "BaseNavigationController.h"
#import "CustomAlert.h"
#import "SDLAESUtil.h"

@interface RequestInstance ()<NSCopying,NSMutableCopying>

@end

#define ResponseErrorDomain @"com.yajie_superlist.ResponseErrorDomain"

static RequestInstance *instance;
static AFHTTPSessionManager *sessionManage;

@implementation RequestInstance

+ (instancetype)shareInstance{
    
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        
        NSURLSessionConfiguration *sessionConfiguraiton = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        sessionManage = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguraiton];
        sessionManage.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManage.responseSerializer = [AFHTTPResponseSerializer serializer];
        sessionManage.requestSerializer.timeoutInterval = 10.0f;
        // 设置请求头
        //        [sessionManage.requestSerializer setValue:kImageSafeChain forHTTPHeaderField:@"Referer"];
        
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone{
    
    return instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    
    return instance;
}

-(NSString *)toJSON:(NSDictionary *)dict{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}


- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters usableStatus:(void (^)(NSDictionary *))usableStatusBlock unusableStatus:(void (^)(NSDictionary *))unusableStatusBlock error:(void (^)(NSError *))errorBlock{
    
    NSMutableDictionary *parames;
    if (parameters) {
        parames = [parameters mutableCopy];
    } else {
        parames = [NSMutableDictionary dictionary];
    }
    
    //机器自动生成
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"machineCode"] != nil ) {
        
        parames[@"token"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"machineCode"];
    }
    
    //如果登录成功会有token  =  00000000-4bc5-bcea-ffff-ffff976ebde5 测试token
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (token && ![token isEqualToString:@""]) {
        parames[@"token"] = token;
    }
    
    //如果登录会有手机号
    NSString *mobile = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mobile"];
    if (mobile && ![mobile isEqualToString:@""]) {
        parames[@"mobile"] = mobile;
    }
    
//    parames[@"token"] = @"00000000-4bc5-bcea-ffff-ffff976ebde5";
//    parames[@"mobile"] = @"15838113123";
    
    
    parames[@"from_type"] = @4;
    
    // 版本号
    NSString *localVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    parames[@"version_app"] = localVersion;
    
    NSString *str = [SDLAESUtil AES128Encrypt:[self toJSON:parames]];
    NSLog(@"url === %@,param == %@",URLString,parames);
    
    [sessionManage POST:URLString parameters:@{@"json":str} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *str = [[NSString alloc]initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];//(NSDta*)responseObject转string
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//        NSLog(@"%@",str);
        id json = [SDLAESUtil AES128Decrypt:str];//解密获取json
        json = [json stringByReplacingOccurrencesOfString:@"\0" withString:@""];//去\0
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];//获取Data
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];//获取dict
        
        if (responseData) {
            id status = responseData[@"status"];
            if (!status || [status isEqual:[NSNull null]]) {
                if (errorBlock) {
                    // 数据解析出错
                    NSError *error = [NSError errorWithDomain:ResponseErrorDomain code:ResponseDataExpireError userInfo:[NSDictionary dictionaryWithObject:@"expire数据解析出错" forKey:NSLocalizedDescriptionKey]];
                    errorBlock(error);
                }
                
            } else {
                int statusNum = [status intValue];
                if (statusNum == 0) {
                    
                    if (usableStatusBlock) {
                        // 可用数据回调
                        usableStatusBlock(responseData);
                    }
                    
                } else {
                    
                    if (unusableStatusBlock) {
                        // 不可用数据回调
                        unusableStatusBlock(responseData);
                    }
                    
                }
            }
        } else {
            if (errorBlock) {
                // 数据解析出错
                NSError *error = [NSError errorWithDomain:ResponseErrorDomain code:ResponseDataJSONError userInfo:[NSDictionary dictionaryWithObject:@"获取数据失败请重试" forKey:NSLocalizedDescriptionKey]];
                errorBlock(error);
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

/*单张图片上传*/
-(void)uploadimageName:(NSString *)name imageData:(NSData*)data url:(NSString *)url dealWithBlock:(void (^)(NSDictionary *, NSError *))aBlock{
    
    [sessionManage POST:url parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"pic" fileName:name mimeType:@"image/jpeg"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *str = [[NSString alloc]initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];//(NSDta*)responseObject转string
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        id json = [SDLAESUtil AES128Decrypt:str];//解密获取json
        json = [json stringByReplacingOccurrencesOfString:@"\0" withString:@""];//去\0
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];//获取Data
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];//获取dict
        
        if (aBlock) {
            aBlock(response,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (aBlock) {
            aBlock(nil,error);
        }
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSInteger tag = alertView.tag;
    if (99 == tag) {
        
        [SWTUtils logout];
        
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
        
        // 登录
        UIViewController *currentVC = [self getCurrentVCFrom:[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController];
        LoginVC *loginVC = [[LoginVC alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUTSUCCESS" object:nil userInfo:nil];
        BaseNavigationController *loginNav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
        [currentVC presentViewController:loginNav animated:YES completion:nil];
        
    }
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    UIViewController *currentVC;
    UINavigationController *currentNavigationVC = [(UITabBarController *)rootVC selectedViewController];
    currentVC = [currentNavigationVC visibleViewController];
    return currentVC;
}

@end

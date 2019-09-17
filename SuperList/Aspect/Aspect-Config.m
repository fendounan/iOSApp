//
//  Aspect-Config.m
//  SuperList
//
//  Created by SWT on 2017/12/22.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "AppDelegate.h"
#import "RequestInstance.h"

#define AtAspect Config
#define AtAspectOfClass AppDelegate

@classPatchField(AppDelegate)

AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions) {
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Splash") parameters:nil usableStatus:^(NSDictionary *dict) {
        
        NSDictionary *dictData = dict[@"data"];
        
        //如果获取成功，保存整个开屏对象
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dictData forKey:@"advertDict"];
        
        if([dictData.allKeys containsObject:@"Picture"]){
            
            if([dictData[@"Picture"] length] >0){
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictData[@"Picture"]]];
                    if (data) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [data writeToFile:[self imagePath] atomically:YES];
                            [[NSUserDefaults standardUserDefaults] setObject:[self imagePath] forKey:@"advertisementImg"];
                        });
                    }else{
                        
                        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"advertisementImg"];
                    }
                });
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"advertisementImg"];
            }
        }
    } unusableStatus:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
    return XAMessageForward(application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);
}
- (NSString *)imagePath
{
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [pathcaches objectAtIndex:0];
    return [cacheDirectory stringByAppendingString:@"advertisement.png"];
}
@end

#undef AtAspectOfClass
#undef AtAspect

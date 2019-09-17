//
//  SWTReachability.m
//  SuperList
//
//  Created by SWT on 2017/12/15.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTReachability.h"
#import "AFNetworking.h"

@implementation SWTReachability

+ (instancetype)shareInstance{
    static SWTReachability *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SWTReachability alloc] init];
        [instance monitoringNetwork];
    });
    return instance;
}

- (void)monitoringNetwork{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            _isNetworkReachable = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SWTNetworkNotReachable" object:nil];
        } else {
            _isNetworkReachable = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SWTNetworkReachable" object:nil];
        }
    }];
}

@end

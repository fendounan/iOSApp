//
//  SWTReachability.h
//  SuperList
//
//  Created by SWT on 2017/12/15.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWTReachability : NSObject

/**
 网络是否链接：网络不可链接时发送“SWTNetworkNotReachable”通知，可链接时发送“SWTNetworkReachable”通知
 YES: 有网络链接
 NO:没有网络链接
 */
@property (nonatomic, assign, readonly) BOOL isNetworkReachable;

+ (instancetype)shareInstance;

@end

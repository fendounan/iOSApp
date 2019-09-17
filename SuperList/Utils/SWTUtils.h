//
//  SWTUtils.h
//  SuperList
//
//  Created by SWT on 2017/11/15.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SWTUtils : NSObject

//获取UUID
+ (NSString *)getUniqueStrByUUID;

+ (NSString *)getRandomStringWithNum:(NSInteger)num;

+ (NSURL *)appstoreURL;

/** 把double类型转为字符串：只保留两位小数点（不进行四舍五入) */
+ (NSString *)stringFromDoubleValue:(double)value;

// 找出导航栏下面的黑线
+ (UIImageView *)findHairlineImageViewUnder:(UIView *)view;

// 退出登录，清除本地保存的信息
+ (void)logout;

/**
 根据accuracy来确认originalStr小数点后保留几位，不足是结果自动补0,超过的直接截掉
 
 @param originalStr 需要操作的字符串
 @param accuracy 小数点后的精度
 @return 操作后的结果
 */
+ (NSString *)decimalsStringWithString:(NSString *)originalStr accuracy:(int)accuracy;

//修改html样式
+(NSString *)webViewhtmlStr:(NSString *)htmlText;

// 判断是否是纯数字字符串：YES: 是  NO:不是
+ (BOOL)isNumber:(NSString *)checkedNumString;
// 判断是否是由数字或字母组成
+ (BOOL)isNumberOrAlphabet:(NSString *)checkedString;

// 判断是否是4.0的屏
+ (BOOL)is4Screen;

// 判断是否登录vip用户
+ (BOOL)isLoginV;
// 判断是否登录
+ (BOOL)isLogin;

+ (BOOL)isSetting;
@end

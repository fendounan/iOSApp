//
//  SWTTimeUtils.h
//  SuperList
//
//  Created by SWT on 2017/11/30.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWTTimeUtils : NSObject

/** 当前时间戳 */
+ (NSTimeInterval)currentTimestamp;

/** 世界时间转换为本地时间 */
+ (NSDate *)worldDateToLocalDate:(NSDate *)date;

/** 格式化日期 */
+ (NSString *)formatDate:(NSDate *)date format:(NSString *)format;
/** 根据timestamp格式化日期 */
+ (NSString *)formatTime:(NSTimeInterval)timestamp format:(NSString *)format;

/** 判断两个日期的时间差 */
+ (NSTimeInterval)timeIntervalWithFirstDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate;
/** 判断两个时间戳之间的时间差 */
+ (NSTimeInterval)timeIntervalWithFirstTimestamp:(NSTimeInterval)firstTimestamp secondTimestamp:(NSTimeInterval)secondTimestamp;

// 判断一个时间是几天前
+ (int)severalDaysWithTimeInterval:(NSTimeInterval)timeInterval;

/**
 判断两个日期相隔几天:24小时一天

 @param beginDate 开始日期
 @param endDate 结束日期
 @return 间隔天数
 */
+ (NSInteger)getCountOfTwoDaysWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;

/**
 判断两个日期相隔几天：只算中间间隔的天数

 @param beginDate 开始日期
 @param endDate 结束日期
 @return 间隔的天数
 */
+ (NSInteger)intervalDaysWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;

/**
 获取一个日期的后一天

 */
+ (NSDate *)tommowDateAccordingDate:(NSDate *)date;

// 判断两个日期是否是同一天
+ (BOOL)isSameDay:(NSDate *)firstDay secondDay:(NSDate *)secondDay;

@end

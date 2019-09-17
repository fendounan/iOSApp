//
//  SWTTimeUtils.m
//  SuperList
//
//  Created by SWT on 2017/11/30.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTTimeUtils.h"

@implementation SWTTimeUtils

// 当前时间戳
+ (NSTimeInterval)currentTimestamp{
    return [[NSDate date] timeIntervalSince1970];
}

// 时间时间转本地时间
+ (NSDate *)worldDateToLocalDate:(NSDate *)date{
    // 获取本地时区
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    // 计算世界时间与本地时区的时间偏差值
    NSInteger offset = [localTimeZone secondsFromGMTForDate:date];
    // 时间时间 + 偏差值 得出本地时间
    NSDate *localDate = [date dateByAddingTimeInterval:offset];
    return localDate;
}

// 格式化日期
+ (NSString *)formatDate:(NSDate *)date format:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *formatterDate = [dateFormatter stringFromDate:date];
    return formatterDate;
}

// 根据timestamp来获取日期并格式化
+ (NSString *)formatTime:(NSTimeInterval)timestamp format:(NSString *)format{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [SWTTimeUtils formatDate:date format:format];
}

// 判断两个时间戳之间的时间差
+ (NSTimeInterval)timeIntervalWithFirstTimestamp:(NSTimeInterval)firstTimestamp secondTimestamp:(NSTimeInterval)secondTimestamp{
    if (firstTimestamp == secondTimestamp) {
        return 0;
    } else {
        if (firstTimestamp > secondTimestamp) {
            return firstTimestamp - secondTimestamp;
        } else {
            return secondTimestamp - firstTimestamp;
        }
    }
}

// 判断两个日期之间的时间差
+ (NSTimeInterval)timeIntervalWithFirstDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate{
    NSTimeInterval firstTimestamp = [firstDate timeIntervalSince1970];
    NSTimeInterval secondTimestamp = [secondDate timeIntervalSince1970];
    return [SWTTimeUtils timeIntervalWithFirstTimestamp:firstTimestamp secondTimestamp:secondTimestamp];
}

// 判断一个时间是几天前
+ (int)severalDaysWithTimeInterval:(NSTimeInterval)timeInterval{
    double result = timeInterval / (24 * 3600);
    return (int)result;
}

// 判断两个日期相隔几天
+ (NSInteger)getCountOfTwoDaysWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateCom = [calendar components:unit fromDate:beginDate toDate:endDate options:0];
    return dateCom.day;
}

+ (NSInteger)intervalDaysWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    beginDate = [SWTTimeUtils tommowDateAccordingDate:beginDate];
    NSDateComponents *components = [calendar components:unit fromDate:beginDate];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)components.year];
    NSString *month = [NSString stringWithFormat:@"%02ld",(long)components.month];
    NSString *day = [NSString stringWithFormat:@"%02ld",(long)components.day];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    beginDate = [formater dateFromString:dateStr];
    beginDate = [SWTTimeUtils worldDateToLocalDate:beginDate];
    
    components = [calendar components:unit fromDate:endDate];
    year = [NSString stringWithFormat:@"%ld",(long)components.year];
    month = [NSString stringWithFormat:@"%02ld",(long)components.month];
    day = [NSString stringWithFormat:@"%02ld",(long)components.day];
    
    dateStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    endDate = [formater dateFromString:dateStr];
    endDate = [self worldDateToLocalDate:endDate];
    
    return [self getCountOfTwoDaysWithBeginDate:beginDate endDate:endDate];
}

+ (NSDate *)tommowDateAccordingDate:(NSDate *)date{
    return [date dateByAddingTimeInterval:24 * 60 * 60];
}


// 判断两个日期是否是同一天
+ (BOOL)isSameDay:(NSDate *)firstDay secondDay:(NSDate *)secondDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    // 第一个日期
    NSDateComponents *nowComponents = [calendar components:unit fromDate:firstDay];
    // 第二个日期
    NSDateComponents *otherComponents = [calendar components:unit fromDate:secondDay];
    
    return (nowComponents.year == otherComponents.year) && (nowComponents.month == otherComponents.month) && (nowComponents.day == otherComponents.day);
}

@end

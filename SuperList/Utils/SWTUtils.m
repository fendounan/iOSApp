//
//  SWTUtils.m
//  SuperList
//
//  Created by SWT on 2017/11/15.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTUtils.h"
#import "MD5Util.h"

@implementation SWTUtils

//获取UUID
+ (NSString *)getUniqueStrByUUID {
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStrRef= CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *retStr = [NSString stringWithString:[NSString stringWithFormat:@"%@",uuidStrRef]];
    CFRelease(uuidStrRef);
    retStr = [retStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return retStr;
}

+ (NSString *)getRandomStringWithNum:(NSInteger)num{
    NSString *string = [[NSString alloc] init];
    for (int i = 0; i < num; i++) {
        if (i < 6) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d",figure];
            string = [string stringByAppendingString:tempString];
        } else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c",character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}


+ (void)logout{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"eusername"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"real_name"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ephone"];
}

//返回appstore url
+ (NSURL *)appstoreURL{
    
#define APP_STORE_ID 1404391096 //Change this one to your ID
    
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";
    
    return [NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, APP_STORE_ID]];
}

+ (NSString *)stringFromDoubleValue:(double)value{
    NSInteger sumInt = (NSInteger)(value * 100);
    double sumSub = (double)sumInt / 100;
    return  [NSString stringWithFormat:@"%.2f",sumSub];
}

+ (UIImageView *)findHairlineImageViewUnder:(UIView *)view{
    if ([view isKindOfClass:[UIImageView class]] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

+ (NSString *)decimalsStringWithString:(NSString *)originalStr accuracy:(int)accuracy{
    NSString *resultStr = nil;
    if (originalStr.length > 0 && accuracy >= 0) {
        // 添加要显示的0
        NSMutableString *supplementZero = [NSMutableString string];
        for (int i = 0; i < accuracy; i++) {
            [supplementZero appendString:@"0"];
        }
        
        if ([originalStr containsString:@"."]) {
            NSString *strDecimal = [[[[originalStr componentsSeparatedByString:@"."] lastObject] stringByAppendingString:supplementZero] substringToIndex:accuracy];
            resultStr = [NSString stringWithFormat:@"%@.%@",[[originalStr componentsSeparatedByString:@"."] firstObject],strDecimal];
        } else {
            resultStr = [NSString stringWithFormat:@"%@.%@",originalStr,supplementZero];
        }
    }
    return resultStr;
}

#pragma mark format HTMLStr
//更改html样式
+(NSString *)webViewhtmlStr:(NSString *)htmlText
{
    float fontSize = 12;
    NSString *fontFamily = @"微软雅黑";
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %f; font-family: \"%@\";}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", fontSize, fontFamily, htmlText];
    return jsString;
}

+ (BOOL)isNumber:(NSString *)checkedNumString{
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (checkedNumString.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isNumberOrAlphabet:(NSString *)checkedString{
    NSString *regex = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:checkedString];
}

+ (BOOL)is4Screen{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (screenW == 320 && screenH == 568) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isLoginV
{
    NSString *IsAuth = [[NSUserDefaults standardUserDefaults] objectForKey:@"IsAuth"];
    if(IsAuth&&[IsAuth intValue] == 1){
        return YES;
    }else
    {
        return NO;
    }
}

+ (BOOL)isLogin
{
    NSString *mobile = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mobile"];
    if(mobile&&![mobile isEqualToString:@""]){
        return YES;
    }else
    {
        return NO;
    }
}

+ (BOOL)isSetting
{
    //如果登录就不过问
    NSString *mobile = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mobile"];
    if(mobile&&![mobile isEqualToString:@""]){
        return NO;
    }else
    {
        NSString *appleVerify = [[NSUserDefaults standardUserDefaults] objectForKey:@"appleVerify"];
        if(appleVerify&&[appleVerify intValue] == 1){
            return YES;
        }else
        {
            return NO;
        }
    }
    
}

@end

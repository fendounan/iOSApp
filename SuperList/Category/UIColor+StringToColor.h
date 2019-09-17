//
//  UIColor+StringToColor.h
//  ZongTongHui
//
//  Created by hdf on 14-10-10.
//  Copyright (c) 2014年 ___MOBILETEAM___. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Main_Red @"#F33632"
#define Main_ViewBG @"#F1F2F6"
#define Main_yellow @"ffa303"
@interface UIColor (StringToColor)
/**
 *  十六进制颜色
 *
 *  @param stringToConvert 十六进制颜色值
 *
 *  @return UIcolor
 */
+(UIColor *) hexStringToColor: (NSString *) stringToConvert;
@end

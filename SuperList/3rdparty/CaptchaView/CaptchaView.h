//
//  CaptchaView.h
//  LocalCaptcha
//
//  Created by jerei on 15-5-23.
//  Copyright (c) 2015年 jerehedu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CaptchaViewDelegate <NSObject>
-(void)getNetWorkCode;
@end
@interface CaptchaView : UIView
@property (nonatomic, retain) NSArray *changeArray; //字符素材数组
@property (nonatomic, retain) NSMutableString *changeString;  //验证码的字符串
@property (nonatomic, assign) id < CaptchaViewDelegate >delegate;
@end

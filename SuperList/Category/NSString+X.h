//
//  NSString+X.h
//  NCENew
//
//  Created by 丁岑 on 15/1/20.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString(X)

- (BOOL)validateWithPattern:(NSString *)pattern;
- (NSString*)numCutted;
- (NSString*)shortNum;

- (UIImage*)imageByAppendImage:(UIImage *)appendix;

- (NSString *)urlencode;

+(NSString *)webViewhtmlStr:(NSString *)htmlText;
@end

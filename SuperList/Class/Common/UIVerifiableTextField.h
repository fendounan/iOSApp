//
//  UILabel+X.h
//  NCENew
//
//  Created by palxex on 15/2/3.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIVerifiableTextField:UITextField

- (void)setValue:(id)value forKey:(NSString*)key;
- (id)valueForKey:(NSString *)key;

- (BOOL)isEmpty;
- (BOOL)verify;
- (NSString*)verifyFailMessage;
@end

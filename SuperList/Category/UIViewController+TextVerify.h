//
//  UIViewController+TextVerify.h
//  NCENew
//
//  Created by palxex on 15/2/7.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(TextVerify)
@property (nonatomic,strong) NSMutableArray *textFields;
@property (nonatomic) SEL finished;

- (id)safeGetStringValue:(NSDictionary *)dict key:(NSString*)key;
- (id)safeGetStringValue:(NSDictionary *)dict key:(NSString*)key orig:(BOOL)orig;

- (void)setTextFieldsNeedVerify:(NSArray *)textFields withFinishedSelector:(SEL)finishedSEL;
- (BOOL)verifyAllTextFields;
@end

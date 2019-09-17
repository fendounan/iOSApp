//
//  UIViewController+KVC.h
//  NCENew
//
//  Created by palxex on 15/2/6.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(KVC)

@property (nonatomic,strong) NSMutableDictionary *_kvcDict;
@property (nonatomic,strong) NSMutableDictionary *KVCDict;

- (void)setObject:(id)value forKeyedSubscript:(NSString *)key;
- (void)setObject:(id)value forUnknownKey:(NSString *)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)mergeKVC:(UIViewController*)vc;
@end

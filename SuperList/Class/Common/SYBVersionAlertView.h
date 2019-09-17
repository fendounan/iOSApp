//
//  SYBVersionAlertView.h
//  SuperList
//
//  Created by SWT on 2018/1/15.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYBVersionAlertView;

@protocol SYBVersionAlertViewDelegate <NSObject>

@optional
- (void)versionUpdate:(SYBVersionAlertView *)alertView;
@end 

@interface SYBVersionAlertView : UIView

@property (nonatomic, copy, readonly) NSArray *contentArr;
@property (nonatomic, assign, readonly) BOOL isForceUpdating;
@property (nonatomic, weak) id<SYBVersionAlertViewDelegate> delegate;

/**
 初始化方法

 @param contentArr 更新内容
 @param delegate 代理
 @param isForceUpdating 是否是强制更新
 @return 初始化对象
 */
- (instancetype)initWithContent:(NSArray *)contentArr delegate:(id)delegate forceUpdating:(BOOL)isForceUpdating;

- (void)show;
- (void)hide;

@end

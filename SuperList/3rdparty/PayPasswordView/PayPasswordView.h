//
//  PayPasswordView.h
//  PayPassword
//
//  Created by SWT on 2017/6/6.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PayPasswordView;

@protocol PayPasswordViewDelegate <NSObject>

@optional

/** 输入完成 */
- (void)inputCompleted:(PayPasswordView *)payPasswordView password:(NSString *)password;

@end

@interface PayPasswordView : UIView
@property (nonatomic, weak) id<PayPasswordViewDelegate> delegate;
@end

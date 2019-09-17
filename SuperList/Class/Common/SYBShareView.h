//
//  SYBShareView.h
//  SuperList
//
//  Created by SWT on 2017/11/23.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYBShareModel;
@interface SYBShareView : UIView

@property (nonatomic, strong) SYBShareModel *shareModel;
@property (nonatomic, strong) UIViewController *rootViewController;

+ (instancetype)shareViewWithModel:(SYBShareModel *)shareModel;
- (instancetype)initWithModel:(SYBShareModel *)shareModel;

- (void)show;
- (void)hideAnimated:(BOOL)animated;

@end

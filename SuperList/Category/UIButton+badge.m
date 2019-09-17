//
//  UIButton+badge.m
//  SDL
//
//  Created by 胡定锋Mac on 2017/1/9.
//  Copyright © 2017年 胡定锋. All rights reserved.
//

#import "UIButton+badge.h"

@implementation UIButton (badge)

- (void)showBadgeOnItem{
    
    //移除之前的小红点
    [self removeBadgeOnItem];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888;
    badgeView.layer.cornerRadius = 4;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    CGFloat x = ceilf(0.6 * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:badgeView];
    
}

- (void)hideBadgeOnItem{
    
    //移除小红点
    [self removeBadgeOnItem];
    
}

- (void)removeBadgeOnItem{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 888) {
            
            [subView removeFromSuperview];
            
        }
    }
}
@end

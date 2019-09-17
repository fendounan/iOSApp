//
//  FlagsLayoutView.h
//  SDL
//
//  Created by 胡定锋Mac on 2016/12/26.
//  Copyright © 2016年 胡定锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlagsLayoutView : UIView<UIGestureRecognizerDelegate>
{
    CGRect previousFrame;
    NSInteger totalHeight;
}
/**
 *  整个View的背景颜色
 */
@property (nonatomic, strong) UIColor *BigBGColor;
/**
 *  设置子标签View的单一颜色
 */
@property (nonatomic, strong) UIColor *singleTagColor;
/**
 *  标签文本数组的赋值
 */
-(void)setTagWithTagArray:(NSArray *)arr;
@end

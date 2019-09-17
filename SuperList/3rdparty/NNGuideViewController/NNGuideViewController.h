//
//  NNGuideViewController.h
//  NCENew
//
//  Created by palxex on 15/3/18.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NNGuideViewController : UIViewController

+ (instancetype)Instance;
- (void)setImages:(NSArray*)array;
- (BOOL)show:(UIViewController*)vc;

// 最后一个图上面的按钮点击事件
@property (nonatomic, copy) void(^finishedBlock)();

@end

//
//  AppDelegate.h
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)BaseTabBarController *mainTabbarVC;

@end


//
//  HomeIndustryVC.h
//  SuperList
//
//  Created by XuYan on 2018/7/3.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseViewController.h"

@protocol HomeIndustryVCDelegate<NSObject>

- (void)searchResult:(NSString *)sResult;

@end

@interface HomeIndustryVC : BaseViewController

@property (nonatomic,weak)id<HomeIndustryVCDelegate>delegate;

@end

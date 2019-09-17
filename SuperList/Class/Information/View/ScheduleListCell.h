//
//  ScheduleListCell.h
//  SuperList
//
//  Created by XuYan on 2018/7/12.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyTaskModel;
@interface ScheduleListCell : UITableViewCell
@property (nonatomic, strong) MyTaskModel *cellmodel;
@property (nonatomic, assign) Boolean isDelete;
@end

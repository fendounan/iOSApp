//
//  MessageListCell.h
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageListModel;

@interface MessageListCell : UITableViewCell

@property (nonatomic, strong) MessageListModel *cellmodel;
@end

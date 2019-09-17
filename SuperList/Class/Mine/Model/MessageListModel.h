//
//  MessageListModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface MessageListModel : BaseModel

@property (nonatomic,copy)NSString <Optional>*Mobile;
@property (nonatomic,copy)NSString <Optional>*DevId;
@property (nonatomic,copy)NSString <Optional>*Text;

@property (nonatomic,copy)NSString <Optional>*TargetMobile;
@property (nonatomic,copy)NSString <Optional>*AddTime;
@property (nonatomic,copy)NSString <Optional>*Id;

@end

//
//  MyTaskModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/12.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface MyTaskModel : BaseModel


@property (nonatomic,copy)NSString <Optional> *DevId;
@property (nonatomic,copy)NSString <Optional> *Mobile;
@property (nonatomic,copy)NSString <Optional> *TaskText;
@property (nonatomic,copy)NSString <Optional> *TaskTime;


@property (nonatomic,copy)NSString <Optional> *IsClock;
@property (nonatomic,copy)NSString <Optional> *CreateTime;
@property (nonatomic,copy)NSString <Optional> *UploadTime;
@property (nonatomic,copy)NSString <Optional> *IsDelete;


@property (nonatomic,copy)NSString <Optional> *Id;
@property (nonatomic,copy)NSString <Optional>*isSelect;

@end

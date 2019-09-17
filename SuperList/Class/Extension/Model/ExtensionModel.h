//
//  ExtensionModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/9.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface ExtensionModel : BaseModel

@property (nonatomic, strong) NSString <Optional> *id;
@property (nonatomic, strong) NSString <Optional> *Name;
@property (nonatomic, strong) NSString <Optional> *OrderId;
@property (nonatomic, strong) NSString <Optional> *Intro;
@property (nonatomic, strong) NSString <Optional> *Ico;

@end

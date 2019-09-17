//
//  InformationModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/10.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface InformationModel : BaseModel

@property (nonatomic,copy)NSString <Optional>*Name;
@property (nonatomic,copy)NSMutableArray <Optional>*Categorys;
@property (nonatomic,copy)NSString <Optional>*OrderId;
@property (nonatomic,copy)NSString <Optional>*Intro;
@property (nonatomic,copy)NSString <Optional>*Ico;

@end

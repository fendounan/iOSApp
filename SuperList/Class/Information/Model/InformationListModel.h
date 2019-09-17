//
//  InformationListModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface InformationListModel : BaseModel


@property (nonatomic,copy)NSString <Optional>*categoryid;
@property (nonatomic,copy)NSString <Optional>*title;
@property (nonatomic,copy)NSString <Optional>*img_url;
@property (nonatomic,copy)NSString <Optional>*imgType;
@property (nonatomic,copy)NSString <Optional>*IndustryCategoryCode;
@property (nonatomic,copy)NSString <Optional>*zhaiyao;
@property (nonatomic,copy)NSString <Optional>*Hit;
@property (nonatomic,copy)NSString <Optional>*OperatorId;
@property (nonatomic,copy)NSString <Optional>*CreateTime;
@property (nonatomic,copy)NSString <Optional>*LastUpdateTime;
@property (nonatomic,copy)NSString <Optional>*URL;
@property (nonatomic,copy)NSString <Optional>*StatusId;

@property (nonatomic,copy)NSString <Optional>*iOrder;
@property (nonatomic,copy)NSString <Optional>*IsNew;
@property (nonatomic,copy)NSString <Optional>*Id;


@end

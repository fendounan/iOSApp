//
//  HomeQueryModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/4.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface HomeQueryModel : BaseModel
@property (nonatomic,strong)NSString <Optional>*compname;
@property (nonatomic,strong)NSString <Optional>*tel;
@property (nonatomic,strong)NSString <Optional>*istele;
@property (nonatomic,strong)NSString <Optional>*comp;
@property (nonatomic,strong)NSString <Optional>*address;
@property (nonatomic,strong)NSString <Optional>*city;
@property (nonatomic,strong)NSString <Optional>*province;
@property (nonatomic,strong)NSString <Optional>*area;
@property (nonatomic,strong)NSString <Optional>*fromtype;
@property (nonatomic,strong)NSString <Optional>*category;
@property (nonatomic,strong)NSString <Optional>*IsNew;
@property (nonatomic,strong)NSString <Optional>*Id;
@end

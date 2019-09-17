//
//  InformationCategorysModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/10.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface InformationCategorysModel : BaseModel
@property (nonatomic,copy)NSString <Optional>*ParentId;
@property (nonatomic,copy)NSString <Optional>*CategoryName;
@property (nonatomic,copy)NSString <Optional>*CreateTime;
@property (nonatomic,copy)NSString <Optional>*IndustryId;
@property (nonatomic,copy)NSString <Optional>*OrderId;
@property (nonatomic,copy)NSString <Optional>*Ico;
@property (nonatomic,copy)NSString <Optional>*ListContainer;
@property (nonatomic,copy)NSString <Optional>*Url;
@property (nonatomic,copy)NSString <Optional>*IsNew;
@property (nonatomic,copy)NSString <Optional>*Id;
@end

//
//  HelpCenterModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface HelpCenterModel : BaseModel

@property (nonatomic,copy)NSString <Optional>*Title;
@property (nonatomic,copy)NSString <Optional>*Content;
@property (nonatomic,copy)NSString <Optional>*OrderId;
@property (nonatomic,copy)NSString <Optional>*Id;

@end

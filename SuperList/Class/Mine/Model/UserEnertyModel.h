//
//  UserEnertyModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/13.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface UserEnertyModel : BaseModel

@property (nonatomic,copy)NSString <Optional>*DevId;
@property (nonatomic,copy)NSString <Optional>*State;
@property (nonatomic,copy)NSString <Optional>*StateString;

@property (nonatomic,copy)NSString <Optional>*ActiveCode;
@property (nonatomic,copy)NSString <Optional>*Mobile;
@property (nonatomic,copy)NSString <Optional>*Password;
@property (nonatomic,copy)NSString <Optional>*Wx;


@property (nonatomic,copy)NSString <Optional>*QQ;
@property (nonatomic,copy)NSString <Optional>*Nickname;
@property (nonatomic,copy)NSString <Optional>*registtime;
@property (nonatomic,copy)NSString <Optional>*stoptime;


@property (nonatomic,copy)NSString <Optional>*CardId;
@property (nonatomic,copy)NSString <Optional>*Type;
@property (nonatomic,copy)NSString <Optional>*ShowOrigin;//showorigin=1，你就显示这个来源网站，如果是0，就不要显示了
@property (nonatomic,copy)NSString <Optional>*ShowTele;//ShowTele=1，显示固话，如果是0，过滤

@property (nonatomic,copy)NSString <Optional>*Rows;
@property (nonatomic,copy)NSString <Optional>*Id;
@property (nonatomic,copy)NSString <Optional>*QueryCnt;
@property (nonatomic,copy)NSString <Optional>*AddCnt;

@property (nonatomic,copy)NSString <Optional>*ShareCnt;
@property (nonatomic,copy)NSString <Optional>*IsAuth;
@property (nonatomic,copy)NSString <Optional>*imob;

@end

//
//  ExtensionListModel.h
//  SuperList
//
//  Created by XuYan on 2018/7/9.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "BaseModel.h"

@interface ExtensionListModel : BaseModel


@property (nonatomic, strong) NSString <Optional> *id;
@property (nonatomic, strong) NSString <Optional> *Name;
@property (nonatomic, strong) NSString <Optional> *CategoryName;
@property (nonatomic, strong) NSString <Optional> *IsNavigate;
@property (nonatomic, strong) NSString <Optional> *Url;

@property (nonatomic, strong) NSString <Optional> *Picture;
@property (nonatomic, strong) NSString <Optional> *title;
@property (nonatomic, strong) NSString <Optional> *mobile;
@property (nonatomic, strong) NSString <Optional> *addtime;

@property (nonatomic, strong) NSString <Optional> *IsVerify;
@property (nonatomic, strong) NSString <Optional> *VerifyTime;
@end

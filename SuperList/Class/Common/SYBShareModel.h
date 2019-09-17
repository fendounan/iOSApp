//
//  SYBShareModel.h
//  SuperList
//
//  Created by SWT on 2017/11/23.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SYBShareModel : JSONModel

@property (nonatomic, strong) NSString <Optional> *ShareAppTitle;
@property (nonatomic, strong) NSString <Optional> *ShareAppTrip;
@property (nonatomic, strong) NSString <Optional> *ShareAppLogo;
@property (nonatomic, strong) NSString <Optional> *ShareAppUrl;

@end

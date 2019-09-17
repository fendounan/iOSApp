//
//  BaseModel.h
//  SuperList
//
//  Created by hdf on 16/8/22.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BaseModel : JSONModel


-(instancetype)initWithJson:(NSString *)json;
@end

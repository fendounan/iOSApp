//
//  BaseModel.m
//  SuperList
//
//  Created by hdf on 16/8/22.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(instancetype)initWithJson:(NSString *)json
{
    JSONModelError *error;
    BaseModel *result =[super initWithString:json error:&error];
    return result;
}
@end

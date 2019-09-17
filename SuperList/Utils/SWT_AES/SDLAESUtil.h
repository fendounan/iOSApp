//
//  SDLAESUtil.h
//  sandaile
//
//  Created by 胡定锋Mac on 2016/11/12.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

#define gkey            @"09a7614dba5cd876" // 2aa0b3ea22cb1c5cd9894abea07e5bc5
#define gIv             @"dya2nw285ghn3n07" //自行修改

@interface SDLAESUtil : NSObject
+ (NSString*) AES128Encrypt:(NSString *)plainText;

+ (NSString*) AES128Decrypt:(NSString *)encryptText;

@end

//
//  NSData+AES256.h
//  sandaile
//
//  Created by 胡定锋Mac on 2016/11/12.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
@interface NSData (AES256)
-(NSData *)aes256_encrypt:(NSString *)key;
-(NSData *)aes256_decrypt:(NSString *)key;
@end


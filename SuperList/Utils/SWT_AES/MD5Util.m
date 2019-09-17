//
//  MD5Util.m
//  UNSPayCenterDemo
//
//  Created by WenJun on 13-11-14.
//  Copyright (c) 2013年 上海银生宝支付服务有限公司. All rights reserved.
//

#import "MD5Util.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5Util

+ (NSString *)md5FromString:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++)
    {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    //    return [outputString uppercaseString];
    return outputString;
}

@end

//
//  UILabel+X.m
//  NCENew
//
//  Created by palxex on 15/2/3.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "UIVerifiableTextField.h"
#import "NSObject+X.h"
#import "NSString+X.h"
static NSDictionary *methodErratas;
static NSDictionary *methodPatterns;

@interface UIVerifiableTextField() {
    NSMutableDictionary *kvcDict;
}

@end

@implementation UIVerifiableTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    [[self class] onInit];
    self = [super initWithCoder:aDecoder];
    kvcDict = [NSMutableDictionary dictionary];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    [[self class] onInit];
    self = [super initWithFrame:frame];
    kvcDict = [NSMutableDictionary dictionary];
    return self;
}

+ (void)onInit {
    if( !methodPatterns )
        methodPatterns = @{@"email":            @"^[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$",
                           @"phone":            @"^(0|\\+)?(86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$",
                           @"personal_id":      @"(^\\d{15}$)|(^\\d{17}([0-9]|X)$)",
                           @"chinese_realname": @"^[\u4e00-\u9fa5]{2,}$",
                           @"username":         @"^([\\w\\d]{4,16})|([\u4e00-\u9fa5\\w\\d]{2,8})$",
                           @"null":             @".*",
                           };
    if( !methodErratas )
        methodErratas  = @{@"email":            @"Email地址格式不正确，请重新输入",
                           @"phone":            @"手机号格式不正确，请重新输入",
                           @"personal_id":      @"身份证号不正确，请重新输入",
                           @"chinese_realname": @"未输入真实姓名，请检查",
                           @"username":         @"用户名格式不正确，请重新输入",
                           @"null":             @"",
                           };
    NSAssert([methodPatterns.allKeys isEqualToArray:methodErratas.allKeys], @"检查与错误信息不匹配!");
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key{
    kvcDict[key]=value;
}
- (id)valueForKey:(NSString *)key{
    id result = [super valueForKey:key];
    if( result != nil && [self hasKVCKey:key] ) {
        result = kvcDict[key];
    }
    return result;
}
- (BOOL)hasKVCKey:(NSString *)key{
    return kvcDict && [kvcDict.allKeys containsObject:key];
}
- (BOOL)isEmpty {
    return [self.text isEqualToString:@""];
}

- (BOOL)verify {
    static NSString *verify_key=@"verify_method";
    BOOL result = YES;
    if( [self.text isEqualToString:@""] )
        result = NO;
    else if( [self hasKVCKey:verify_key] ) {
        NSString *verify_method=kvcDict[verify_key];
        if( [methodPatterns.allKeys containsObject:verify_method] ) {
            NSString *verifyPattern = methodPatterns[verify_method];
            result = [self.text validateWithPattern:verifyPattern];
        }
    }
    return result;
}
- (NSString*)verifyFailMessage{
    static NSString *verify_key=@"verify_method";
    static NSString *notfound = @"请输入完整再提交";
    NSString *result = notfound;
    if( [self hasKVCKey:verify_key] ) {
        NSString *verify_method=kvcDict[verify_key];
        if( [methodErratas.allKeys containsObject:verify_method] ) {
            result = methodErratas[verify_method];
        }
    }
    return result;
}

@end

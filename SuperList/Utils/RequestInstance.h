//
//  RequestInstance.h
//  SanYiBao
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ResponseDataErrorCode){
    ResponseDataExpireError = -1000,
    ResponseDataStatusError,
    ResponseDataJSONError,
    ResponseDataOtherError
};

@interface RequestInstance : NSObject

+ (instancetype)shareInstance;

/**
 POST请求
 
 @param URLString 请求接口
 @param parameters 请求参数
 @param usableStatusBlock 可用状态数据
 @param unusableStatusBlock 不可用状态数据
 @param errorBlock 网络错误
 */
- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters usableStatus:(void (^)(NSDictionary *dic))usableStatusBlock unusableStatus:(void (^)(NSDictionary *dic))unusableStatusBlock error:(void (^)(NSError *error))errorBlock;

-(void)uploadimageName:(NSString *)name
             imageData:(NSData*)data
                   url:(NSString *)url
         dealWithBlock:(void (^)(NSDictionary *, NSError *))aBlock;

@end

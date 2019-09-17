//
//  SWTLocationManager.m
//  SuperList
//
//  Created by XuYan on 2018/7/25.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "SWTLocationManager.h"
#import <CoreLocation/CLLocationManager.h>

@implementation SWTLocationManager
#pragma mark 判断是否打开定位

+(BOOL)determineWhetherTheAPPOpensTheLocation{
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorized)) {
        
        return YES;
        
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        
        return NO;
        
    }else{
        
        return NO;
        
    }
    
}
@end

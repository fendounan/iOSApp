//
//  UIViewController+KVC.m
//  NCENew
//
//  Created by palxex on 15/2/6.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "UIViewController+KVC.h"
#import "NSObject+X.h"

@implementation UIViewController(KVC)
ADD_MUTABLE_DYNAMIC_PROPERTY(NSMutableDictionary *, _kvcDict,        set_kvcDict);

- (NSMutableDictionary *)KVCDict {
    if( !self._kvcDict ) {
        self._kvcDict = [NSMutableDictionary dictionary];
    }
    return self._kvcDict;
}

- (void)setKVCDict:(NSMutableDictionary *)KVCDict {
    self._kvcDict = KVCDict;
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)key {
    self.KVCDict[key]=value;
}

- (void)setObject:(id)value forUnknownKey:(NSString *)key {
    self.KVCDict[key]=value;
}

- (void)mergeKVC:(UIViewController*)vc {
    [self.KVCDict addEntriesFromDictionary:vc.KVCDict];
}

- (id)objectForKeyedSubscript:(id)key {
    if( [self.KVCDict.allKeys containsObject:key] )
        return self.KVCDict[key];
    return @"not found";
}

@end

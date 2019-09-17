//
//  NSObject+X.m
//  NCENew
//
//  Created by palxex on 15/2/3.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "NSObject+X.h"
#import <objc/runtime.h>

@implementation NSObject(X)

+ (void)swizzleArray:(NSArray *)originalSelectors with:(NSArray *)swizzledSelectors {
    NSAssert(originalSelectors.count == swizzledSelectors.count, @"original and swizzled not identical!");
    
    SEL originalSelector = NULL;
    SEL swizzledSelector = NULL;
    for( int i = 0; i < originalSelectors.count; i++) {
        NSValue *originalValue = originalSelectors[i];
        NSValue *swizzledValue = originalSelectors[i];
        [originalValue getValue:&originalSelector];
        [swizzledValue getValue:&swizzledSelector];
        [self swizzle:originalSelector with:swizzledSelector];
    }
}
+ (void)swizzle:(SEL)originalSelector with:(SEL)swizzledSelector {
    Class class = [self class];
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

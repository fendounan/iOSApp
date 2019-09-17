//
//  NSObject+X.h
//  NCENew
//
//  Created by palxex on 15/2/3.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE )objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
}

#define ADD_MUTABLE_DYNAMIC_PROPERTY(PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE )objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , [PROPERTY_NAME mutableCopy] , OBJC_ASSOCIATION_RETAIN); \
}

#define ADD_DYNAMIC_BOOL_PROPERTY(PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( BOOL ) PROPERTY_NAME \
{ \
NSNumber *result = objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
return [result boolValue]; \
} \
\
- (void) SETTER_NAME :( BOOL ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , @(PROPERTY_NAME) , OBJC_ASSOCIATION_RETAIN); \
}

#define ADD_DYNAMIC_INT_PROPERTY(PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( int ) PROPERTY_NAME \
{ \
NSNumber *result = objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
return [result intValue]; \
} \
\
- (void) SETTER_NAME :( int ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , @(PROPERTY_NAME) , OBJC_ASSOCIATION_RETAIN); \
}

#define ADD_DYNAMIC_SEL_PROPERTY(PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
static SEL sel##PROPERTY_NAME; \
- ( SEL ) PROPERTY_NAME \
{ \
NSValue *result = objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
[result getValue:&sel##PROPERTY_NAME];\
return sel##PROPERTY_NAME; \
} \
\
- (void) SETTER_NAME :( SEL ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , [NSValue valueWithPointer:PROPERTY_NAME] , OBJC_ASSOCIATION_RETAIN); \
}

@interface NSObject(X)
+ (void)swizzle:(SEL)originalSelector with:(SEL)swizzledSelector;
//+ (void)swizzleArray:(NSArray *)originalSelectors with:(NSArray *)swizzledSelector;
@end

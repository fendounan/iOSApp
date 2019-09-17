//
//  UIViewController+TextVerify.m
//  NCENew
//
//  Created by palxex on 15/2/7.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "UIViewController+TextVerify.h"
#import "UIVerifiableTextField.h"
#import "NSObject+X.h"
#import "SWTProgressHUD.h"
#import "NSString+X.h"
@implementation UIViewController(TextVerify)
ADD_MUTABLE_DYNAMIC_PROPERTY(NSMutableArray *,              textFields,        setTextFields);
ADD_DYNAMIC_SEL_PROPERTY(finished, setFinished);

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    BOOL ret = YES;
    
    for (int v=0; v<self.textFields.count; v++) {
        if( v!= self.textFields.count-1 ) {
            if( textField == self.textFields[v] ) {
                [self.textFields[v+1] becomeFirstResponder];
                break;
            }
        }else
            if( textField == self.textFields[v] ) {
                [self.view endEditing:YES];
                [self finishedInput];
                break;
            }
    }
    return ret;
}

- (void)finishedInput {
    if( [self verifyAllTextFields]  )
    {
        if(self.finished)
            [self performSelector:self.finished withObject:nil afterDelay:0];
        return;
    }
}

- (void)setTextFieldsNeedVerify:(NSArray *)newTextFields withFinishedSelector:(SEL)finishedSEL {
    for( UITextField *textField in newTextFields ) {
        if( ![textField isKindOfClass:[UITextField class]] ) {
            NSAssert(NO, @"%@ is not textfield!", textField);
            return;
        }
    }
    self.textFields = [newTextFields mutableCopy];
    self.finished = finishedSEL;
}

- (BOOL)verifyAllTextFields {
    [self.view endEditing:YES];
    BOOL verified = YES;
    NSString *errata = @"请输入完整再提交";
    for( UITextField *textField in self.textFields ) {
        if( [textField isKindOfClass:[UIVerifiableTextField class]] ) {
            UIVerifiableTextField *verifiableTextField = (UIVerifiableTextField *)textField;
            if(![verifiableTextField verify]){
                verified = NO;
                errata = [verifiableTextField verifyFailMessage];
                break;
            }
        }
    }
    if( !verified ) {
        [SWTProgressHUD toastMessageAddedTo:nil message:[NSString stringWithFormat:@"失败:%@",errata]];
    }
    return verified;
}

- (id)safeGetStringValue:(NSDictionary *)dict key:(NSString*)key{
    return [self safeGetStringValue:dict key:key orig:NO];
}

- (id)safeGetStringValue:(NSDictionary *)dict key:(NSString*)key orig:(BOOL)orig{
    id result = nil;
    if( [dict.allKeys containsObject:key] ) {
        result = dict[key];
        if( orig ) {
            if ([result isEqual:[NSNull null]]) {
                result = @"0.00";
            } else {
                if( [result isKindOfClass:[NSNumber class]] )
                    result = [[@([[NSString stringWithFormat:@"%.2f",[result doubleValue]] doubleValue]) stringValue] numCutted];
            }
            
        }else {
            if( [result isKindOfClass:[NSNumber class]] )
                result = [[result stringValue] shortNum];
            else if( !(fabs([result doubleValue]) < 0.00001) )
                result = [result shortNum];
        }
    }
    return result;
}

@end

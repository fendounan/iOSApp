//
//  CustomAlert.m
//  NCENew
//
//  Created by hdf on 16/6/20.
//  Copyright © 2016年 cn.edu.ustc. All rights reserved.
//

#import "CustomAlert.h"

@implementation CustomAlert

-(void)drawRect:(CGRect)rect{
    self.frame  = [[UIScreen mainScreen] bounds];
    [[[[UIApplication sharedApplication]delegate]window] addSubview:self];
    
    self.alertView.center = self.center;
}
- (IBAction)sure:(id)sender {

    if (_delegate && [_delegate respondsToSelector:@selector(alertClick)]) {
        [_delegate alertClick];
    }
    exit(0);
}

@end

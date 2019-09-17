//
//  UILabel+Custom.m
//  SDL
//
//  Created by 胡定锋Mac on 2016/12/30.
//  Copyright © 2016年 胡定锋. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel (Custom)


-(void)setFixFontSize:(BOOL)fixFontSize
{
    self.adjustsFontSizeToFitWidth = YES;
    if (iPhone4)
    {
        NSLog(@"4");
        self.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize * 1.0];
    }else if(iPhone5){
        NSLog(@"5");

        self.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize * 1.05];
    }
    else if (iPhone6p)
    {
        NSLog(@"6+");
        self.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize * 1.2];
    }else if(iPhone6){
        
        NSLog(@"6");
        
        self.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize * 1.1];
    }
//    self.minimumScaleFactor = self.font.pointSize;
}

@end

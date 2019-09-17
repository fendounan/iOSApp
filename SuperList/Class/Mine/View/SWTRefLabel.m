//
//  SWTRefLabel.m
//  SuperList
//
//  Created by apple on 2018/1/8.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "SWTRefLabel.h"

@implementation SWTRefLabel
{
    UIActivityIndicatorView *iactivity;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    iactivity = [[UIActivityIndicatorView alloc]initWithFrame:rect];
    iactivity.backgroundColor = self.backgroundColor;
    [iactivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    [self addSubview:iactivity];

}

-(void)startActivity{
    
    [self addSubview:iactivity];
    [iactivity startAnimating];
}

-(void)stopActivity{
    [iactivity stopAnimating];
    [iactivity removeFromSuperview];

}

@end

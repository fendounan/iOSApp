//
//  SWTCustomNavBar.m
//  SuperList
//
//  Created by SWT on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTCustomNavBar.h"

@interface SWTCustomNavBar ()

@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, assign) CGFloat hairlineH;

@end

@implementation SWTCustomNavBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
        [self initConfig];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpView];
        [self initConfig];
    }
    return self;
}

- (void)setUpView{
    
    _shadowImageView = [[UIImageView alloc] init];
    _shadowImageView.backgroundColor = [UIColor colorWithRed:179 / 255.0 green:179 / 255.0 blue:179 / 255.0 alpha:1.0];
    [self addSubview:_shadowImageView];
    
    _backgroundImageView = [[UIImageView alloc] init];
    [self addSubview:_backgroundImageView];
    
    _titleLab = [[UILabel alloc] init];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLab];
    
}

- (void)initConfig{
    _hairlineH = 0.5;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLab.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    self.titleLab.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    self.titleLab.textColor = titleColor;
}

- (void)setHairHidden:(BOOL)hairHidden{
    if (hairHidden) {
        _hairlineH = 0;
    } else {
        _hairlineH = 0.5;
    }
}

- (void)leftBarWithImage:(UIImage *)barImage target:(id)target selector:(SEL)selector{
    BOOL imageCondition = YES;
    BOOL targetCondition = YES;
    if (!barImage) {
        imageCondition = NO;
        NSAssert(imageCondition, @"please transfer a image");
    }
    
    if (!target) {
        targetCondition = NO;
        NSAssert(targetCondition, @"please transfer a target");
    }
    
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_leftButton];
    }
    [_leftButton setImage:barImage forState:UIControlStateNormal];
    [_leftButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)rightBarWithImage:(UIImage *)barImage target:(id)target selector:(SEL)selector{
    BOOL imageCondition = YES;
    BOOL targetCondition = YES;
    if (!barImage) {
        imageCondition = NO;
        NSAssert(imageCondition, @"please transfer a image");
    }
    
    if (!target) {
        targetCondition = NO;
        NSAssert(targetCondition, @"please transfer a target");
    }
    
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_rightButton];
    }
    [_rightButton setImage:barImage forState:UIControlStateNormal];
    [_rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCustomNavBarBackgroundImage:(UIImage *)customNavBackgroundImage{
    _backgroundImageView.image = customNavBackgroundImage;
}

- (void)setCustomNavBarBackgroundColor:(UIColor *)customNavBackgroundColor{
    _backgroundImageView.backgroundColor = customNavBackgroundColor;
}

- (void)setHairlineColor:(UIColor *)hairlineColor{
    _hairlineColor = hairlineColor;
    
    _shadowImageView.backgroundColor = hairlineColor;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat leftSpace = 0;
    CGFloat rightSpace = 3;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    if (screenW == 320 && screenH == 568) { // 4.0屏手机
        rightSpace = 3;
    } else if (screenW == 414 && screenH == 736) { // 5.5屏手机
        rightSpace = 7;
    } else if (screenW == 375 && screenH == 667) {
        rightSpace = 3;
    }
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat widgeH = 44;
    CGFloat buttonW = 44;
    CGFloat widgeY = height - widgeH - _hairlineH;
    
    _shadowImageView.frame = CGRectMake(0, height - _hairlineH, width, _hairlineH);
    
    _backgroundImageView.frame = CGRectMake(0, 0, width, height - _hairlineH);
    
    if (_leftButton) {
        _leftButton.frame = CGRectMake(leftSpace, widgeY, buttonW, widgeH);
    }
    
    if (_rightButton) {
        _rightButton.frame = CGRectMake(width - rightSpace - buttonW , widgeY, buttonW, widgeH);
    }
    
    _titleLab.frame = CGRectMake(leftSpace + buttonW, widgeY, width - leftSpace - buttonW - rightSpace - buttonW, widgeH);
}

@end

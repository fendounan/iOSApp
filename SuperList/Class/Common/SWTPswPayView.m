//
//  SWTPswPayView.m
//  SuperList
//
//  Created by SWT on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTPswPayView.h"
#import "UIView+Frame.h"
#import "NSString+Size.h"
#import "UIColor+StringToColor.h"
#import "PayPasswordView.h"

@interface SWTPswPayView ()<PayPasswordViewDelegate>

@property (nonatomic, strong) UIView *maskView;

@end

@implementation SWTPswPayView

+ (instancetype)payViewWithPrice:(NSString *)price headingString:(NSString *)heading delegate:(id)delegate{
    
    SWTPswPayView *payView = [[SWTPswPayView alloc] initWithPrice:price headingString:heading delegate:delegate];
    return payView;
}

- (instancetype)initWithPrice:(NSString *)price headingString:(NSString *)heading delegate:(id)delegate{
    _heading = heading;
    _delegate = delegate;
    _price = price;
    return [self init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView]; 
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpView]; 
    }
    return self;
}

- (void)setUpView{
    
    [self initConfig];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    // 左右边距
    CGFloat leftRightSpace = screenW * 0.064;
    CGFloat padding = 16.5;
    CGFloat selfWidth =  screenW - leftRightSpace * 2;
    self.frame = CGRectMake(0, screenH / 2, selfWidth, 0);
    
    UILabel *topLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, selfWidth, 49)];
    topLab.text = @"请输入交易密码";
    topLab.textAlignment = NSTextAlignmentCenter;
    topLab.textColor = [UIColor hexStringToColor:@"#333333"];
    topLab.font = [UIFont systemFontOfSize:18];
    [self addSubview:topLab];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"project_pay_delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.frame = CGRectMake(0, 0, 24, 24);
    deleteBtn.center = CGPointMake(selfWidth - padding - 14, topLab.centerY);
    [self addSubview:deleteBtn];
    
    UIView *topSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLab.frame), selfWidth, 0.5)];
    topSeperatorView.backgroundColor = [UIColor hexStringToColor:@"#e2e2e2"];
    [self addSubview:topSeperatorView];
    
    UILabel *investFixLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topSeperatorView.frame) + 15, selfWidth, 18)];
//    investFixLab.text = @"投资";
    investFixLab.text = _heading;
    investFixLab.textAlignment = NSTextAlignmentCenter;
    investFixLab.textColor = [UIColor hexStringToColor:@"#333333"];
    investFixLab.font = [UIFont systemFontOfSize:15];
    [self addSubview:investFixLab];
    
    UILabel *investLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(investFixLab.frame) + 30, selfWidth, 30)];
    investLab.font = [UIFont systemFontOfSize:36];
    investLab.textColor = [UIColor hexStringToColor:@"#333333"];
    investLab.text = _price;
    investLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:investLab];
    
    NSString *RMBStr = @"¥";
    NSString *investStr = [NSString stringWithFormat:@"%@%@",RMBStr,_price];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:investStr];
    [attributedText addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} range:[investStr rangeOfString:RMBStr]];
    [attributedText addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:36]} range:[investStr rangeOfString:_price]];
    investLab.attributedText = attributedText;
    
    CGFloat centerSeperatorViewX = (selfWidth - padding * 2) / 12 + padding;
    UIView *centerSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(centerSeperatorViewX, CGRectGetMaxY(investLab.frame) + 13, selfWidth - centerSeperatorViewX * 2, 0.5)];
    centerSeperatorView.backgroundColor = [UIColor hexStringToColor:@"#e2e2e2"];
    [self addSubview:centerSeperatorView];
    
    CGFloat payPswViewW = selfWidth - padding * 2;
    CGFloat payPswViewH = payPswViewW * 84 / 498;
    PayPasswordView *payPswView = [[PayPasswordView alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(centerSeperatorView.frame) + 40, payPswViewW, payPswViewH)];
    payPswView.delegate = self;
    [self addSubview:payPswView];
    
    self.x = leftRightSpace;
    self.height = CGRectGetMaxY(payPswView.frame) + 32.5;
}

- (void)initConfig{
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissAction:(UIButton *)sender{
    [self hideAnimated:YES];
}

- (void)show{
    _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _maskView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.40];
    [_maskView addSubview:self];
    [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
}

- (void)hideAnimated:(BOOL)animated{
    [self endEditing:YES];
}

#pragma mark - notification

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyBoardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    
    CGFloat offset = 0;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (screenW == 320 && screenH == 568) { // 4.0的屏
        offset = 20;
    } else {
        offset = 80;
    }
    [UIView animateWithDuration:animationDuration animations:^{
        self.y = [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height - offset - self.height;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    CGFloat animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    [UIView animateWithDuration:animationDuration animations:^{
        self.centerY = [UIScreen mainScreen].bounds.size.height / 2;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

#pragma mark - PayPasswordViewDelegate

- (void)inputCompleted:(PayPasswordView *)payPasswordView password:(NSString *)password{
    if (_delegate && [_delegate respondsToSelector:@selector(inputCompleted:password:)]) {
        [_delegate inputCompleted:self password:password]; 
    }
    [self hideAnimated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end

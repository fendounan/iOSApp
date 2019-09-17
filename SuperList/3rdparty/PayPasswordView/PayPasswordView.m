//
//  PayPasswordView.m
//  PayPassword
//
//  Created by SWT on 2017/6/6.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "PayPasswordView.h"
#import "PayPasswordTF.h"

#define kDotSize CGSizeMake (10, 10) //密码点的大小
#define kDotCount 6  //密码个数
#define K_Field_Height self.frame.size.height //每一个输入框的高度

@interface PayPasswordView ()<UITextFieldDelegate>

@property (nonatomic, strong) PayPasswordTF *textField;
/** 用于存放黑色的点 */
@property (nonatomic, strong) NSMutableArray *dotArray;

@end

@implementation PayPasswordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.cornerRadius = 3;
        [self initPwdTextField];
        [self.textField becomeFirstResponder];
    }
    return self;
}

- (void)initPwdTextField
{
    //每个密码输入框的宽度
    CGFloat width = self.frame.size.width / kDotCount;
    
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (i + 1) * width, 0, 0.5, K_Field_Height)];
        lineView.backgroundColor = [UIColor colorWithRed:188 / 255.0 green:188 / 255.0 blue:188 / 255.0 alpha:1.0];
        [self addSubview:lineView];
    }
    
    self.dotArray = [[NSMutableArray alloc] init];
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (width - kDotCount) / 2 + i * width, CGRectGetMinY(self.textField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = [UIColor blackColor];
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}

/**
 *  清除密码
 */
- (void)clearUpPassword
{
    self.textField.text = @"";
    [self textFieldDidChange:self.textField];
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
    if (textField.text.length == kDotCount) {
        
        // 输入完毕
        if (_delegate && [_delegate respondsToSelector:@selector(inputCompleted:password:)]) {
            [_delegate inputCompleted:self password:self.textField.text];
        }
    }
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[PayPasswordTF alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, K_Field_Height)];
        _textField.backgroundColor = [UIColor clearColor];
        //输入的文字颜色为白色
        _textField.textColor = [UIColor clearColor];
        //输入框光标的颜色为白色
        _textField.tintColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.borderColor = [[UIColor colorWithRed:188 / 255.0 green:188 / 255.0 blue:188 / 255.0 alpha:1.0] CGColor];
        _textField.layer.borderWidth = 0.5;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_textField];
    }
    return _textField;
}

#pragma mark - UITextFieldDelegate

// 禁止复制粘贴
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if ([UIMenuController sharedMenuController]) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSLog(@"变化%@", string);
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= kDotCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
//        NSLog(@"输入的字符个数大于6，忽略输入");
        return NO;
    } else {
        return YES;
    }
}
@end

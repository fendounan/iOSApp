//
//  SWTCommentBox.m
//  SuperList
//
//  Created by SWT on 2017/12/21.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTCommentBox.h"
#import "Masonry.h"
#import "UIColor+StringToColor.h"
#import "UIView+Frame.h"

@interface SWTCommentBox ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UIView *topSeperatorView;
@property (nonatomic, strong) UIView *verticalSeperatorView;

@end

#define TEXTVIEWHEIGHT 36
#define TOPSPACE 5
#define BOTTOMSPACE 5

@implementation SWTCommentBox{
    CGFloat _keyboardH;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit{
    
    _keyboardH = 0;
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self registerNotification];
    
    [self addSubview:self.topSeperatorView];
    [self addSubview:self.textView];
    [self addSubview:self.sendBtn];
    [self addSubview:self.verticalSeperatorView];
    
    CGFloat navigationBarH;
    if (CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectMake(0, 0, 375, 812))) {
        navigationBarH = 88;
    } else {
        navigationBarH = 64;
    }
    
    self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - navigationBarH, [UIScreen mainScreen].bounds.size.width, TEXTVIEWHEIGHT + TOPSPACE + BOTTOMSPACE);
    
    [self.topSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topSeperatorView.mas_bottom);
        make.right.bottom.equalTo(self);
        make.width.mas_equalTo(75);
    }];
    
    [self.verticalSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_sendBtn.mas_left);
        make.top.equalTo(_topSeperatorView.mas_bottom).offset(TOPSPACE + BOTTOMSPACE);
        make.bottom.equalTo(self.mas_bottom).offset(-TOPSPACE - BOTTOMSPACE);
        make.width.mas_equalTo(1);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(self.mas_top).offset(TOPSPACE);
        make.bottom.equalTo(self.mas_bottom).offset(-BOTTOMSPACE);
        make.right.equalTo(_verticalSeperatorView.mas_left).offset(-5);
    }];
    
    [self.textView becomeFirstResponder];
}

- (void)updateFrame:(CGFloat)height{
//    CGFloat currentH = height + TOPSPACE + BOTTOMSPACE;
//    CGFloat totalH = TEXTVIEWHEIGHT + TOPSPACE + BOTTOMSPACE;
//    if (currentH < totalH) {
//        CGFloat navigationBarH;
//        if (CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectMake(0, 0, 375, 812))) {
//            navigationBarH = 88;
//        } else {
//            navigationBarH = 64;
//        }
//        
//        self.height = TEXTVIEWHEIGHT + TOPSPACE + BOTTOMSPACE;
//        self.y = [UIScreen mainScreen].bounds.size.height - navigationBarH - _keyboardH - self.height;
//    } else {
//        CGFloat currentH = height + TOPSPACE + BOTTOMSPACE;
//        if (self.height >= currentH) {
//            return;
//        } else {
//            self.height = currentH;
//            CGFloat navigationBarH;
//            if (CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectMake(0, 0, 375, 812))) {
//                navigationBarH = 88;
//            } else {
//                navigationBarH = 64;
//            }
//            self.y = [UIScreen mainScreen].bounds.size.height - navigationBarH - _keyboardH - self.height;
//        }
//    }
}

- (void)cleanUpMessage{
    self.textView.text = @"";
}

#pragma mark - action

- (void)sendMessage:(UIButton *)sendBtn{
    if (self.textView.text.length >0) {
        if (self.delegate &&[self.delegate respondsToSelector:@selector(commentBoxSendMessage:)]) {
            [self.delegate commentBoxSendMessage:self.textView.text];
        }
    }
//    self.textView.text = @"";
}

#pragma mark - notification

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat navigationBarH;
    _keyboardH = keyboardFrame.size.height;
    if (CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectMake(0, 0, 375, 812))) {
        navigationBarH = 88;
    } else {
        navigationBarH = 64;
    }
    [UIView animateWithDuration:duration animations:^{
        self.y = [UIScreen mainScreen].bounds.size.height - navigationBarH - self.height - _keyboardH;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
//    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        self.y = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - lazy load

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.scrollsToTop = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIView *)topSeperatorView{
    if (!_topSeperatorView) {
        _topSeperatorView = [[UIView alloc] init];
        _topSeperatorView.backgroundColor = [UIColor hexStringToColor:@"#e2e2e2"];
    }
    return _topSeperatorView;
}

- (UIView *)verticalSeperatorView{
    if (!_verticalSeperatorView) {
        _verticalSeperatorView = [[UIView alloc] init];
        _verticalSeperatorView.backgroundColor = [UIColor hexStringToColor:@"#e2e2e2"];
    }
    return _verticalSeperatorView;
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        if (self.textView.text.length >0) {
            if (self.delegate &&[self.delegate respondsToSelector:@selector(commentBoxSendMessage:)]) {
                [self.delegate commentBoxSendMessage:self.textView.text];
            }
        }
//        self.textView.text = @"";
//        self.textView.height = TEXTVIEWHEIGHT;
        [self textViewDidChange:self.textView];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self updateFrame:ceilf([textView sizeThatFits:textView.frame.size].height)];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

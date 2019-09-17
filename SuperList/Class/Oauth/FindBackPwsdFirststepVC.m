//
//  FindBackPwsdFirststepVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/15.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "FindBackPwsdFirststepVC.h"
#import "Masonry.h"
#import "SWTProgressHUD.h"
#import "SWTUtils.h"
#import "FindBackPwsdSecondstepVC.h"

@interface FindBackPwsdFirststepVC ()
//手机号
@property (nonatomic, strong) UITextField *tfPhone;
//验证码
@property (nonatomic, strong) UITextField *tfVerificationCode;

@property (nonatomic, strong) SWTProgressHUD *hud;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UIButton *verificationCodeBtn;

@end

@implementation FindBackPwsdFirststepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"找回密码";
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    self.navigationController.navigationBar.barTintColor = [UIColor hexStringToColor:mColor_TopTarBg];
    [self setUpView];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    
}

- (void)setUpView{
    
    CGFloat padding = 15;
    
    UIView *vPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 44)];
    vPhone.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:vPhone];
    //手机号
    UILabel *vlabPhoneLeft = [[UILabel alloc] init];
    vlabPhoneLeft.text = @"手机号：";
    vlabPhoneLeft.textColor = [UIColor hexStringToColor:@"#333333"];
    vlabPhoneLeft.font = FONT(15);
    [vPhone addSubview:vlabPhoneLeft];
    [vlabPhoneLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vPhone).offset(padding);
        make.top.bottom.equalTo(vPhone);
    }];
    UITextField *tfPhone = [[UITextField alloc] init];
    self.tfPhone = tfPhone;
    tfPhone.placeholder = @"注册所用的手机号";
    tfPhone.keyboardType = UIKeyboardTypePhonePad;
    tfPhone.font = FONT(14);
    tfPhone.textColor = [UIColor hexStringToColor:@"#333333"];
    // 设置清除模式
    tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
    //设置左边视图的宽度
    tfPhone.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
    //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
    tfPhone.leftViewMode = UITextFieldViewModeAlways;
    [vPhone addSubview:tfPhone];
    
    [tfPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(vPhone);
        make.right.equalTo(vPhone);
        make.left.equalTo(vlabPhoneLeft.mas_right).offset(10);
    }];
    
    //验证码
    UIView *vVerificationCode = [[UIView alloc] initWithFrame:CGRectMake(0, 76, kScreenWidth, 44)];
    vVerificationCode.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:vVerificationCode];
    UILabel *vlabVerificationCodeLeft = [[UILabel alloc] init];
    vlabVerificationCodeLeft.text = @"验证码：";
    vlabVerificationCodeLeft.textColor = [UIColor hexStringToColor:@"#333333"];
    vlabVerificationCodeLeft.font = FONT(15);
    [vVerificationCode addSubview:vlabVerificationCodeLeft];
    [vlabVerificationCodeLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vVerificationCode).offset(padding);
        make.top.bottom.equalTo(vVerificationCode);
    }];
    
    UIButton *verificationCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.verificationCodeBtn = verificationCodeBtn;
    verificationCodeBtn.titleLabel.font = FONT(15);
    [verificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    verificationCodeBtn.backgroundColor = [UIColor whiteColor];
    verificationCodeBtn.layer.cornerRadius = 10;
    verificationCodeBtn.layer.masksToBounds = YES;
    [verificationCodeBtn setTitleColor:[UIColor hexStringToColor:mColor_TopTarBg] forState:UIControlStateNormal];
    [verificationCodeBtn addTarget:self action:@selector(sendVerificationCode) forControlEvents:UIControlEventTouchUpInside];
    [vVerificationCode addSubview:verificationCodeBtn];
    [verificationCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(vVerificationCode).offset(-padding);
        make.width.equalTo(@80);
        make.top.bottom.equalTo(vVerificationCode);
    }];
    
    UITextField *tfVerificationCode = [[UITextField alloc] init];
    self.tfVerificationCode = tfVerificationCode;
    tfVerificationCode.placeholder = @"手机收到的验证码";
    tfVerificationCode.keyboardType = UIKeyboardTypePhonePad;
    tfVerificationCode.font = FONT(14);
    tfVerificationCode.textColor = [UIColor hexStringToColor:@"#333333"];
    // 设置清除模式
    tfVerificationCode.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
    //设置左边视图的宽度
    tfVerificationCode.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
    //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
    tfVerificationCode.leftViewMode = UITextFieldViewModeAlways;
    [vVerificationCode addSubview:tfVerificationCode];
    
    [tfVerificationCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(vVerificationCode);
        make.right.equalTo(verificationCodeBtn.mas_left);
        make.left.equalTo(vlabVerificationCodeLeft.mas_right).offset(10);
        make.top.bottom.equalTo(vVerificationCode);
    }];
    
    
    
    //下一步
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(padding, 150, Main_Screen_Width-2*padding, 44);
    submitBtn.titleLabel.font = FONT(17);
    [submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
    submitBtn.layer.cornerRadius = 10;
    submitBtn.layer.masksToBounds = YES;
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    
}

#pragma mark 网络请求

- (void)submitAction{
    
    NSString *phoneString = self.tfPhone.text;
    
    if (!phoneString.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入手机号"];
        return;
    } else {
        if (phoneString.length != 11) {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号位数错误"];
            return;
        } else {
            if (![SWTUtils isNumber:phoneString]) {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号包含非数字字符"];
                return;
            }
        }
    }
    NSString *vcString = self.tfVerificationCode.text;
    if (!vcString.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入验证码"];
        return;
    }
    [self.view endEditing:YES];
    FindBackPwsdSecondstepVC *findBackPwsdSecondstepVC = [[FindBackPwsdSecondstepVC alloc] init];
    findBackPwsdSecondstepVC.strPhone = phoneString;
    findBackPwsdSecondstepVC.strCode = vcString;
    [self.navigationController pushViewController:findBackPwsdSecondstepVC animated:YES];
    
}

- (void)sendVerificationCode{
    NSString *phoneString = self.tfPhone.text;
    
    if (!phoneString.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入手机号"];
        return;
    } else {
        if (phoneString.length != 11) {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号位数错误"];
            return;
        } else {
            if (![SWTUtils isNumber:phoneString]) {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号包含非数字字符"];
                return;
            }
        }
    }
    
    [self startCountDown];
    
    NSDictionary *parameters = @{@"mobile":phoneString};
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Sms/SendChangePswdCode") parameters:parameters usableStatus:^(NSDictionary *dic) {
        
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"data"][@"message"]];
        
    } unusableStatus:^(NSDictionary *dic) {
        
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        
    } error:^(NSError *error) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
    }];
}

- (void)startCountDown {
    self.verificationCodeBtn.enabled = NO;
    __block int timeout=120; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    _timer = timer;
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.verificationCodeBtn.enabled = YES;
                [self.verificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateDisabled];
            });
        }else{
            NSString *strTime = [NSString stringWithFormat:@"%ds", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.verificationCodeBtn setTitle:strTime forState:UIControlStateDisabled];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

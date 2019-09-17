//
//  FindBackPwsdSecondstepVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/15.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "FindBackPwsdSecondstepVC.h"
#import "Masonry.h"
#import "SWTProgressHUD.h"
#import "SWTUtils.h"
#import "FindBackPwsdFirststepVC.h"

@interface FindBackPwsdSecondstepVC ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *tfPsw1;
//验证码
@property (nonatomic, strong) UITextField *tfPsw2;

@property (nonatomic, strong) SWTProgressHUD *hud;
@end

@implementation FindBackPwsdSecondstepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"找回密码";
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    self.navigationController.navigationBar.barTintColor = [UIColor hexStringToColor:mColor_TopTarBg];
    [self setUpView];
}
- (void)setUpView{
    
    CGFloat padding = 15;
    
    UIView *vPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 44)];
    vPhone.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:vPhone];
    //手机号
    UILabel *vlabPhoneLeft = [[UILabel alloc] init];
    vlabPhoneLeft.text = @"新  密  码：";
    vlabPhoneLeft.textColor = [UIColor hexStringToColor:@"#333333"];
    vlabPhoneLeft.font = FONT(15);
    [vPhone addSubview:vlabPhoneLeft];
    [vlabPhoneLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vPhone).offset(padding);
        make.top.bottom.equalTo(vPhone);
    }];
    UITextField *tfPsw1 = [[UITextField alloc] init];
    self.tfPsw1 = tfPsw1;
    tfPsw1.delegate = self;
    tfPsw1.placeholder = @"6~12位的数字或字母组合";
    tfPsw1.font = FONT(14);
    tfPsw1.textColor = [UIColor hexStringToColor:@"#333333"];
    tfPsw1.keyboardType = UIKeyboardTypeASCIICapable;
    // 设置清除模式
    tfPsw1.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
    //设置左边视图的宽度
    tfPsw1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
    //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
    tfPsw1.leftViewMode = UITextFieldViewModeAlways;
    [vPhone addSubview:tfPsw1];
    
    [tfPsw1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(vPhone);
        make.right.equalTo(vPhone);
        make.left.equalTo(vlabPhoneLeft.mas_right).offset(10);
    }];
    
    //验证码
    UIView *vVerificationCode = [[UIView alloc] initWithFrame:CGRectMake(0, 76, kScreenWidth, 44)];
    vVerificationCode.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:vVerificationCode];
    UILabel *vlabVerificationCodeLeft = [[UILabel alloc] init];
    vlabVerificationCodeLeft.text = @"确认密码：";
    vlabVerificationCodeLeft.textColor = [UIColor hexStringToColor:@"#333333"];
    vlabVerificationCodeLeft.font = FONT(15);
    [vVerificationCode addSubview:vlabVerificationCodeLeft];
    [vlabVerificationCodeLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vVerificationCode).offset(padding);
        make.top.bottom.equalTo(vVerificationCode);
    }];
    UITextField *tfPsw2 = [[UITextField alloc] init];
    self.tfPsw2 = tfPsw2;
    tfPsw2.delegate = self;
    tfPsw2.keyboardType = UIKeyboardTypeASCIICapable;
    tfPsw2.placeholder = @"请再次输入新密码";
    tfPsw2.font = FONT(14);
    tfPsw2.textColor = [UIColor hexStringToColor:@"#333333"];
    // 设置清除模式
    tfPsw2.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
    //设置左边视图的宽度
    tfPsw2.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
    //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
    tfPsw2.leftViewMode = UITextFieldViewModeAlways;
    [vVerificationCode addSubview:tfPsw2];
    
    [tfPsw2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(vVerificationCode);
        make.right.equalTo(vVerificationCode);
        make.left.equalTo(vlabVerificationCodeLeft.mas_right).offset(10);
    }];
    
    
    
    //下一步
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(padding, 150, Main_Screen_Width-2*padding, 44);
    submitBtn.titleLabel.font = FONT(17);
    [submitBtn setTitle:@"完成" forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
    submitBtn.layer.cornerRadius = 10;
    submitBtn.layer.masksToBounds = YES;
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    
}

#pragma mark 网络请求

- (void)submitAction{
    
    NSString *psw1 = self.tfPsw1.text;
    
    NSString *psw2 = self.tfPsw2.text;
    if (!psw1.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入密码"];
        return;
    }
    
    if ([psw1 length]<6 ||[psw1 length]>12) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"密码应为6-12位"];
        return;
    }
    
    if (!psw2.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入确认密码"];
        return;
    }
    if( ![psw1 isEqualToString:psw2] ) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"两次输入密码不一致"];
        return;
    }
    [self.view endEditing:YES];
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍后.."];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"mobile"] =self.strPhone;
    paramesDic[@"code"] =self.strCode;
    paramesDic[@"password"] =self.tfPsw1.text;
    
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Sms/ChkCode") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        //毙掉第一步页面
        NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
        for (UIViewController *vc in marr) {
            if ([vc isKindOfClass:[FindBackPwsdFirststepVC class]]) {
                [marr removeObject:vc];
                break;
            }
        }
        
        self.navigationController.viewControllers = marr;
        [self.navigationController popViewControllerAnimated:YES];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:TEXTFIELDKEYBOARDTYPE] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
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

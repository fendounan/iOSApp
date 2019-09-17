//
//  LoginVC.m
//  SuperList
//
//  Created by SWT on 2017/12/4.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "LoginVC.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+Frame.h"
#import "SWTProgressHUD.h"
#import "RequestInstance.h"
#import "JPUSHService.h"
#import "RegisterVC.h"
#import "SWTUtils.h"
#import "Masonry.h"
#import "JPUSHService.h"
#import "UserEnertyModel.h"
#import "FindBackPwsdFirststepVC.h"

@interface LoginVC ()<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;


@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTop;

@property (nonatomic, strong) UserEnertyModel *userModel;

@end

@implementation LoginVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"Oauth" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    
    [self customInit];
    
}

- (void)customInit{
    
    self.pswTF.secureTextEntry = YES;
    
    NSString *login_user_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mobile"];
    if (login_user_name) {
        self.phoneTF.text = login_user_name;
    }
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss:)]];
    
    self.loginBtn.layer.cornerRadius = 10;
    self.loginBtn.layer.masksToBounds = YES;
    
    [self registerNotification];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationBar];
    self.navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navBarHairlineImageView.hidden = NO;
}

- (void)setNavigationBar{
    
    self.backImage = [UIImage imageNamed:@"navigation_delete"];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}

- (void)back{
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)saveDataWithDic:(NSDictionary *)dict{
    [self.view endEditing:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithDictionary:dict[@"data"]];
    
    [dictData setValue:self.pswTF.text forKey:@"Password"];
    
     _userModel = [[UserEnertyModel alloc]initWithDictionary:dictData error:nil];
    
    _userModel.Password = self.pswTF.text;
    
    
    [userDefaults setObject:dictData forKey:@"user"];
    
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.DevId forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.State forKey:@"State"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.StateString forKey:@"StateString"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.ActiveCode forKey:@"ActiveCode"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Mobile forKey:@"Mobile"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Password forKey:@"Password"];
    
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Wx forKey:@"Wx"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.QQ forKey:@"QQ"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Nickname forKey:@"Nickname"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.registtime forKey:@"registtime"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.stoptime forKey:@"stoptime"];
    
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.CardId forKey:@"CardId"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Type forKey:@"Type"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.ShowOrigin forKey:@"ShowOrigin"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.ShowTele forKey:@"ShowTele"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Rows forKey:@"Rows"];
    
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.Id forKey:@"Id"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.QueryCnt forKey:@"QueryCnt"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.AddCnt forKey:@"AddCnt"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.ShareCnt forKey:@"ShareCnt"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.IsAuth forKey:@"IsAuth"];
    [[NSUserDefaults standardUserDefaults] setObject:_userModel.imob forKey:@"imob"];
    
    //极光别名
    [self pushsetalias:dictData[@"Mobile"]];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGINSUCCESS" object:nil];
    
    [SWTProgressHUD toastMessageAddedTo:nil message:@"登录成功"];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//设置极光推送别名
-(void)pushsetalias:(NSString *)identify
{
    [JPUSHService setAlias:identify completion:nil seq:1002];
}


#pragma mark - notification

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyBoardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    
    CGFloat contentViewH = CGRectGetMaxY(self.loginBtn.frame);
    CGFloat keyboardY = [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height - kStatusBarHeight - kNavigationBarHeight;
    if (keyboardY < contentViewH) {
        CGFloat distance = keyboardY - contentViewH - 20;
        [UIView animateWithDuration:animationDuration animations:^{
            self.containerViewTop.constant = distance;
            [self.view layoutIfNeeded];
        }];
    }

}

- (void)keyboardWillHide:(NSNotification *)notification{
    if (self.containerViewTop.constant != 0) {
        CGFloat animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        [UIView animateWithDuration:animationDuration animations:^{
            self.containerViewTop.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - action

- (void)keyboardDismiss:(UITapGestureRecognizer *)tapGesture{
    [self.view endEditing:YES];
}

// 密码可见性
- (IBAction)securityPswAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pswTF.secureTextEntry = !sender.selected;
}

// 忘记密码
- (IBAction)forgetPswAction:(id)sender {
    
    FindBackPwsdFirststepVC *findBackPwsdFirststepVC = [[FindBackPwsdFirststepVC alloc] init];
    [self.navigationController pushViewController:findBackPwsdFirststepVC animated:YES];
}

// 注册
- (IBAction)registerAction:(id)sender {
    RegisterVC *registerVC = [[RegisterVC alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

// 登录
- (IBAction)loginAction:(id)sender {
    NSString *phoneStr = self.phoneTF.text;
    NSString *pswStr = self.pswTF.text;
    if (!phoneStr.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入手机号"];
        return;
    } else {
        if (phoneStr.length != 11) {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号位数错误"];
            return;
        } else {
            if (![SWTUtils isNumber:phoneStr]) {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"手机号包含非数字字符"];
                return;
            }
        }
    }
    
    if (!pswStr.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入密码"];
        return;
    }
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"mobile"] = phoneStr;
    paramesDic[@"password"] = pswStr;
    
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"正在登录..."];
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Customer/LoginByMobile") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [self saveDataWithDic:dic];
    } unusableStatus:^(NSDictionary *dic) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        [hud hideAnimated:YES];
    } error:^(NSError *error) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        [hud hideAnimated:YES];
    }];
}

- (void)dealloc{
    [self unregisterNotification];
}


@end

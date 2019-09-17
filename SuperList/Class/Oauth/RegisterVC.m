//
//  RegisterVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "RegisterVC.h"
#import "Masonry.h"
#import "SWTUtils.h"
#import "RequestInstance.h"

@interface RegisterVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
//手机号
@property (nonatomic, strong) UITextField *tfPhone;
//昵称
@property (nonatomic, strong) UITextField *tfNickName;
//密码
@property (nonatomic, strong) UITextField *tfPassWord;
//邀请码
@property (nonatomic, strong) UITextField *tfInvitationCode;


@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    self.navigationController.navigationBar.barTintColor = [UIColor hexStringToColor:mColor_TopTarBg];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss:)]];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}
#pragma mark - lazy load

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        CGFloat headerHeight = 30;
        CGFloat cellHeight = 44;
        CGFloat padding = 20;
        CGFloat lineHeight = 0.5;
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        UILabel *topLabName = [[UILabel alloc] initWithFrame:CGRectMake(0, headerHeight, kScreenWidth, cellHeight)];
        topLabName.text = @"超级名录";
        topLabName.textColor = [UIColor hexStringToColor:@"#333333"];
        topLabName.font = FONT(25);
        topLabName.textAlignment = NSTextAlignmentCenter;
        [_tableHeaderView addSubview:topLabName];
        
        
        headerHeight = headerHeight+cellHeight+20;
        
        UIView *vPhone = [[UIView alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, cellHeight)];
        [_tableHeaderView addSubview:vPhone];
        
        UILabel *labLeftPhone = [[UILabel alloc] init];
        labLeftPhone.text = @"+86";
        labLeftPhone.textColor = [UIColor hexStringToColor:@"#333333"];
        labLeftPhone.font = FONT(15);
        [vPhone addSubview:labLeftPhone];
        [labLeftPhone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vPhone);
            make.centerY.equalTo(vPhone);
            make.width.equalTo(@30);
        }];
        
        UIView *linePhone = [[UIView alloc] init];
        linePhone.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [vPhone addSubview:linePhone];
        [linePhone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(labLeftPhone.mas_right).offset(10);
            make.centerY.equalTo(vPhone);
            make.top.equalTo(vPhone).offset(5);
            make.bottom.equalTo(vPhone).offset(-5);
            make.width.mas_equalTo(0.5);
        }];
        
        UITextField *tfPhone = [[UITextField alloc] init];
        self.tfPhone = tfPhone;
        tfPhone.placeholder = @"请输入手机号";
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
            make.left.equalTo(linePhone).offset(10);
        }];
        
        headerHeight = headerHeight+cellHeight+lineHeight;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, lineHeight)];
        line1.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [_tableHeaderView addSubview:line1];
        
        //昵称
        headerHeight = headerHeight+lineHeight;
        UITextField *tfNickName = [[UITextField alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, cellHeight)];
        self.tfNickName = tfNickName;
        tfNickName.placeholder = @"请输入昵称";
        
        tfNickName.font = FONT(14);
        tfNickName.textColor = [UIColor hexStringToColor:@"#333333"];
        // 设置清除模式
        tfNickName.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        //设置左边视图的宽度
        tfNickName.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
        
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        tfNickName.leftViewMode = UITextFieldViewModeAlways;
        [_tableHeaderView addSubview:tfNickName];
        
        headerHeight = headerHeight+cellHeight;
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, lineHeight)];
        line2.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [_tableHeaderView addSubview:line2];
        
        //密码
        headerHeight = headerHeight+lineHeight;
        UITextField *tfPassWord = [[UITextField alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, cellHeight)];
        self.tfPassWord = tfPassWord;
        tfPassWord.placeholder = @"请输入密码6-12位的数字和字母组合";\
        tfPassWord.secureTextEntry = YES;
        tfPassWord.font = FONT(14);
        tfPassWord.textColor = [UIColor hexStringToColor:@"#333333"];
        // 设置清除模式
        tfPassWord.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        //设置左边视图的宽度
        tfPassWord.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        tfPassWord.leftViewMode = UITextFieldViewModeAlways;
        //设置右边视图的宽度
        
        UIButton *rightEye = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightEye setImage:[UIImage imageNamed:@"eye_close"] forState:UIControlStateNormal];
        [rightEye setImage:[UIImage imageNamed:@"eye_open"] forState:UIControlStateSelected];
        [rightEye addTarget:self action:@selector(rightEyeShow:) forControlEvents:UIControlEventTouchUpInside];
        rightEye.frame = CGRectMake(0, 0, 34, 34);
        tfPassWord.rightView = rightEye;
        tfPassWord.rightViewMode = UITextFieldViewModeAlways;
        
        
        [_tableHeaderView addSubview:tfPassWord];
        
        headerHeight = headerHeight+cellHeight;
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, lineHeight)];
        line3.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [_tableHeaderView addSubview:line3];

        //邀请码
        headerHeight = headerHeight+lineHeight;
        UITextField *tfInvitationCode = [[UITextField alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, cellHeight)];
        self.tfInvitationCode = tfInvitationCode;
        tfInvitationCode.placeholder = @"请输入邀请码(可不填写)";
        
        tfInvitationCode.font = FONT(14);
        tfInvitationCode.textColor = [UIColor hexStringToColor:@"#333333"];
        // 设置清除模式
        tfInvitationCode.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        //设置左边视图的宽度
        tfInvitationCode.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
        
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        tfInvitationCode.leftViewMode = UITextFieldViewModeAlways;
        [_tableHeaderView addSubview:tfInvitationCode];
        
        headerHeight = headerHeight+cellHeight+lineHeight;
        UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(padding, headerHeight, kScreenWidth-2*padding, lineHeight)];
        line4.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [_tableHeaderView addSubview:line4];
        
        headerHeight = headerHeight+lineHeight;
        
        
        UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRegister.frame =CGRectMake(padding, headerHeight+20, kScreenWidth-2*padding, cellHeight);
        [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
        btnRegister.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnRegister.titleLabel.font = FONT(15);
        btnRegister.layer.cornerRadius = 10;
        btnRegister.layer.masksToBounds = YES;
        [btnRegister addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
        [_tableHeaderView addSubview:btnRegister];
        
        headerHeight = headerHeight+cellHeight+20;
        
        _tableHeaderView.height = headerHeight;
        
        
    }
    return _tableHeaderView;
}

- (void)rightEyeShow:(id)sender
{
    UIButton *rightEye = (UIButton *)sender;
    if (rightEye.isSelected) {
        [rightEye setSelected:NO];
        self.tfPassWord.secureTextEntry = YES;
    }else
    {
        [rightEye setSelected:YES];
        self.tfPassWord.secureTextEntry = NO;
    }
}

- (void)registerUser
{
    
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
    NSString *pswString = self.tfPassWord.text;
    if (!pswString.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入登录密码"];
        return;
    } else {
        if (pswString.length < 6 || pswString.length > 12) {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"密码为6到12位数字或字母"];
            return;
        } else {
            if (![SWTUtils isNumberOrAlphabet:pswString]) {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"密码为6到12位数字或字母"];
                return;
            }
        }
    }
    
    NSString *nickNameString = self.tfNickName.text;
    if (!nickNameString.length) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入昵称"];
        return;
    }
    [self.view endEditing:YES];
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"mobile"] = phoneString;
    paramesDic[@"password"] = pswString;
    paramesDic[@"nickname"] = self.tfNickName.text;
    paramesDic[@"agencycode"] = self.tfInvitationCode.text;
    
    
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"正在注册..."];
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Customer/Regist") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        [self.navigationController popViewControllerAnimated:YES];
    } unusableStatus:^(NSDictionary *dic) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        [hud hideAnimated:YES];
    } error:^(NSError *error) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        [hud hideAnimated:YES];
    }];
}

#pragma mark - lazy load

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)keyboardDismiss:(UITapGestureRecognizer *)tapGesture{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

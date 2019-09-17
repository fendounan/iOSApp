//
//  MineVC.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "MineVC.h"
#import "Masonry.h"
#import "UIView+Frame.h"
#import "RequestInstance.h"
#import "UserEnertyModel.h"
#import "SWTProgressHUD.h"
#import "BaseNavigationController.h"
#import "UIViewController+Refresh.h"
#import "SWTUtils.h"
#import "SWTCustomNavBar.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIEdgeInsetsUILabel.h"
#import "WantToPromoteVC.h"
#import "FeedBackVC.h"
#import "SWTImageUtils.h"
#import "SYBShareView.h"
#import "SYBShareModel.h"
#import "PPGetAddressBook.h"
#import "ContactUsVC.h"
#import "MessageListVC.h"
#import "ParameterSettingVC.h"
#import "LoginVC.h"



@interface MineVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIView *headView;
@property (nonatomic,strong)UserEnertyModel *userModel;
/** 渐变导航栏 */
@property (nonatomic, strong) SWTCustomNavBar *customNavBar;

/** 头像 */
@property (nonatomic, strong) UIImageView *headerImageView;
/** 用户名 */
@property (nonatomic, strong) UILabel *mineUserName;
/** 手机号 */
@property (nonatomic, strong) UILabel *mineUserMobile;
/** 用户类型 */
@property (nonatomic, strong) UIEdgeInsetsUILabel *mineUserYype;
/** 退出登录 */
@property (nonatomic, strong) UIButton *btnLoginOut;
/** 平均分 数组 */
@property (nonatomic, strong) NSMutableArray *masonryViewArray;
/** 检索数据 */
@property (nonatomic, strong) UILabel *jiansuo_Num;
/** 添加 */
@property (nonatomic, strong) UILabel *tianjia_Num;

/** 添加 */
@property (nonatomic, strong) UILabel *tuiguang_Num;

//分享
@property (nonatomic, strong) SYBShareModel *shareModel;
//普通的等待框
@property (nonatomic, strong) SWTProgressHUD *hud;


@end

@implementation MineVC
{
    CGFloat _headerImageViewWidth;
}

#pragma mark 异常
- (void)showNoNetworkView{
    [self.view addSubview:self.noNetworkView];
    [self.noNetworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)networkReachability{
    [self dismissErrorDataView];
    [self dismissNoNetworkView];
    [self request];
}

- (void)showErrorDataView{
    [self.view addSubview:self.errorDataView];
    
    [self.errorDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)reRequestData{
    
    [self request];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    _headerImageViewWidth = 60.0f;
    self.tableView.hidden = YES;
    [self.view addSubview:self.customNavBar];
    [self.customNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kNavigationBarHeight + kStatusBarHeight);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBar.mas_bottom).offset(-2);
        make.bottom.equalTo(self.view).offset(-(kNavigationBarHeight + kStatusBarHeight));
    }];

    [self setupRefresh:self.tableView hasHeaderRefresh:YES hasFooterRefresh:NO withPage:1 ForSelector:@selector(request)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTableView) name:@"LOGOUTSUCCESS" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navBarHairlineImageView.hidden = YES;
    
    if ([SWTReachability shareInstance].isNetworkReachable) {
        [self setUserData];
        
        [self request];
    }else{
        if (!self.isLoadedData || self.tableView.hidden) {
            [self showNoNetworkView];
        }else{
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络连接失败"];
        }
    }
    
    [self requestAppleVerifyData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navBarHairlineImageView.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navBarHairlineImageView.hidden = NO;
}

#pragma mark 设置用户数据
- (void) setUserData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefaults objectForKey:@"Mobile"];
    if(mobile&&![mobile isEqualToString:@""]){
        self.btnLoginOut.hidden = NO;
        self.mineUserYype.hidden = NO;
        self.mineUserName.text = [userDefaults objectForKey:@"Nickname"];
        self.mineUserMobile.text = [userDefaults objectForKey:@"Mobile"];
        NSString *query = [userDefaults objectForKey:@"QueryCnt"];
        self.jiansuo_Num.text = query;
        NSString *add = [userDefaults objectForKey:@"AddCnt"];
        self.tianjia_Num.text = add;
        NSString *share = [userDefaults objectForKey:@"ShareCnt"];
        self.tuiguang_Num.text = share;
        self.headerImageView.image = [UIImage imageNamed:@"image_login_login"];
    }else{
        self.btnLoginOut.hidden = YES;
        self.mineUserYype.hidden = YES;
        self.mineUserName.text = @"未注册";
        self.mineUserMobile.text = @"登录/注册";
        self.jiansuo_Num.text = @"0个";
        self.tianjia_Num.text = @"0个";
        self.tuiguang_Num.text = @"0个";
        self.headerImageView.image = [UIImage imageNamed:@"avater"];
    }
}
#pragma mark 懒加载
- (SWTCustomNavBar *)customNavBar{
    if (!_customNavBar) {
        _customNavBar = [[SWTCustomNavBar alloc] init];
        [_customNavBar setCustomNavBarBackgroundImage:[UIImage imageNamed:@"navigation_background"]];
        _customNavBar.titleColor = [UIColor whiteColor];
        _customNavBar.titleFont = [UIFont systemFontOfSize:18];
        _customNavBar.title = @"我的账户";
    }
    return _customNavBar;
}
-(UIView *)headView{
    
    if (!_headView) {
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
        _headView.backgroundColor = [UIColor whiteColor];
        CGFloat padding = 20;
        
        UIView *topView = [[UIView alloc] init];
        topView.userInteractionEnabled = YES;
        [topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)]];
        [_headView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(_headView);
            make.height.equalTo(@110);
        }];
        
        UIImageView *imageBgView = [[UIImageView alloc]init];
        imageBgView.image = [UIImage imageNamed:@"mine_bg"];
        [topView addSubview:imageBgView];
        [imageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(topView);
        }];
        
        [topView addSubview:self.headerImageView];
        [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topView).offset(30);
            make.centerY.equalTo(topView);
            //宽高 固定值
            make.width.height.mas_equalTo(_headerImageViewWidth);
        }];
        
        UILabel *mineUserName = [[UILabel alloc] init];
        mineUserName.text = @"未注册";
        mineUserName.textColor = [UIColor whiteColor];
        mineUserName.font = FONT(16);
        [topView addSubview:mineUserName];
        self.mineUserName = mineUserName;
        [mineUserName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headerImageView.mas_right).offset(padding);
            make.top.equalTo(self.headerImageView.mas_top);
        }];
        
        
        UIEdgeInsetsUILabel *mineUserYype = [[UIEdgeInsetsUILabel alloc] init];
        mineUserYype.text = @"普通用户";
        mineUserYype.layer.cornerRadius = 6.0f;
        mineUserYype.layer.masksToBounds = YES;
        mineUserYype.textColor = [UIColor whiteColor];
        mineUserYype.backgroundColor = [UIColor hexStringToColor:@"#e9b413"];
        mineUserYype.font = FONT(12);
        mineUserYype.textInsets = UIEdgeInsetsMake(2.f, 8.f, 2.f, 8.f); // 设置左内边距
        [mineUserYype sizeToFit];
        [topView addSubview:mineUserYype];
        self.mineUserYype = mineUserYype;
        [mineUserYype mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mineUserName.mas_right).offset(10);
            make.centerY.equalTo(mineUserName);
        }];
        
        UILabel *mineUserMobile = [[UILabel alloc] init];
        mineUserMobile.text = @"登录/注册";
        mineUserMobile.textColor = [UIColor whiteColor];
        mineUserMobile.font = FONT(16);
        [topView addSubview:mineUserMobile];
        self.mineUserMobile = mineUserMobile;
        [mineUserMobile mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headerImageView.mas_right).offset(padding);
            make.bottom.equalTo(self.headerImageView.mas_bottom);
        }];
        
        UIButton *btnLoginOut = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnLoginOut setImage:[UIImage imageNamed:@"icon_exit"] forState:UIControlStateNormal];
        [btnLoginOut addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
        self.btnLoginOut = btnLoginOut;
        [topView addSubview:btnLoginOut];
        [btnLoginOut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(topView).offset(-padding);
            make.centerY.equalTo(topView);
            make.width.height.mas_equalTo(_headerImageViewWidth*2/3);
        }];
        
        UIView *viewInfo = [[UIView alloc]init];
        viewInfo.layer.borderColor = [UIColor hexStringToColor:@"#E6E6E6"].CGColor;
        viewInfo.layer.cornerRadius = 5.f;
        viewInfo.layer.borderWidth = 1.f;
        viewInfo.clipsToBounds = YES;
        viewInfo.backgroundColor = [UIColor whiteColor];
        
        [_headView addSubview:viewInfo];
        
        [viewInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headView).offset(10);
            make.right.equalTo(_headView).offset(-10);
            make.top.equalTo(topView.mas_bottom).offset(10);
            make.height.mas_equalTo(60);
        }];
        
        //在信息页面 平均分配三个布局
        UIView *vJianSuo = [[UIView alloc] init];
        [viewInfo addSubview:vJianSuo];
        
        UIView *vTianJia = [[UIView alloc] init];
        [viewInfo addSubview:vTianJia];
        
        UIView *vTuiGuang = [[UIView alloc] init];
        [viewInfo addSubview:vTuiGuang];
        
        [self.masonryViewArray addObject:vJianSuo];
        [self.masonryViewArray addObject:vTianJia];
        [self.masonryViewArray addObject:vTuiGuang];
        // 实现masonry水平固定间隔方法
        [self.masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:1 leadSpacing:0 tailSpacing:0];
        
        // 设置array的垂直方向的约束
        [self.masonryViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
            make.top.bottom.mas_equalTo(viewInfo);
        }];
        
        //添加检索信息
        UIImage *imageJianSuo = [SWTImageUtils createImageWithColor:[UIColor hexStringToColor:@"4286f5"] rectMake:CGRectMake(0, 0, 8, 8)];
        UIButton *btnJianSuo = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnJianSuo setTitle:@"  检索" forState:UIControlStateNormal];
        [btnJianSuo setTitleColor:[UIColor hexStringToColor:@"#999999"] forState:UIControlStateNormal];
        btnJianSuo.titleLabel.font = FONT(12);
        [btnJianSuo setImage:imageJianSuo forState:UIControlStateNormal];
        [vJianSuo addSubview:btnJianSuo];
        [btnJianSuo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(vJianSuo.mas_centerY).offset(-3);
            make.centerX.equalTo(vJianSuo);
        }];
        
        _jiansuo_Num = [[UILabel alloc]init];
        _jiansuo_Num.text = @"0个";
        _jiansuo_Num.font = FONT(14);
        _jiansuo_Num.textColor = [UIColor hexStringToColor:@"#333333"];
        [vJianSuo addSubview:_jiansuo_Num];
        [_jiansuo_Num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vJianSuo.mas_centerY).offset(3);
            make.centerX.equalTo(vJianSuo);
        }];
        
        
        //添加添加信息
        UIImage *imageTianJia = [SWTImageUtils createImageWithColor:[UIColor hexStringToColor:@"02c68d"] rectMake:CGRectMake(0, 0, 8, 8)];
        UIButton *btnTianJia = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTianJia setTitle:@"  添加" forState:UIControlStateNormal];
        [btnTianJia setTitleColor:[UIColor hexStringToColor:@"#999999"] forState:UIControlStateNormal];
        btnTianJia.titleLabel.font = FONT(12);
        [btnTianJia setImage:imageTianJia forState:UIControlStateNormal];
        [vTianJia addSubview:btnTianJia];
        [btnTianJia mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(vTianJia.mas_centerY).offset(-3);
            make.centerX.equalTo(vTianJia);
        }];
        
        _tianjia_Num = [[UILabel alloc]init];
        _tianjia_Num.text = @"0个";
        _tianjia_Num.font = FONT(14);
        _tianjia_Num.textColor = [UIColor hexStringToColor:@"#333333"];
        [vJianSuo addSubview:_tianjia_Num];
        [_tianjia_Num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vTianJia.mas_centerY).offset(3);
            make.centerX.equalTo(vTianJia);
        }];
        
        
        
        //添加推广信息
        UIImage *imageTuiGuang = [SWTImageUtils createImageWithColor:[UIColor hexStringToColor:@"ef5f3a"] rectMake:CGRectMake(0, 0, 8, 8)];
        UIButton *btnTuiGuang = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTuiGuang setTitle:@"  推广" forState:UIControlStateNormal];
        [btnTuiGuang setTitleColor:[UIColor hexStringToColor:@"#999999"] forState:UIControlStateNormal];
        btnTuiGuang.titleLabel.font = FONT(12);
        [btnTuiGuang setImage:imageTuiGuang forState:UIControlStateNormal];
        [vTuiGuang addSubview:btnTuiGuang];
        [btnTuiGuang mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(vTuiGuang.mas_centerY).offset(-3);
            make.centerX.equalTo(vTuiGuang);
        }];
        
        _tuiguang_Num = [[UILabel alloc]init];
        _tuiguang_Num.text = @"0个";
        _tuiguang_Num.font = FONT(14);
        _tuiguang_Num.textColor = [UIColor hexStringToColor:@"#333333"];
        [vJianSuo addSubview:_tuiguang_Num];
        [_tuiguang_Num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vTuiGuang.mas_centerY).offset(3);
            make.centerX.equalTo(vTuiGuang);
        }];
        
        //添加分割线
        CGFloat lineVspace = 5;
        UIView *line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [viewInfo addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vJianSuo.mas_right);
            make.width.equalTo(@1);
            make.top.equalTo(viewInfo).mas_equalTo(lineVspace);
            make.bottom.equalTo(viewInfo).mas_equalTo(-lineVspace);;
        }];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [viewInfo addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vTuiGuang);
            make.width.equalTo(@1);
            make.top.equalTo(viewInfo).mas_equalTo(lineVspace);
            make.bottom.equalTo(viewInfo).mas_equalTo(-lineVspace);;
        }];
        
        
    }
    return _headView;
}

- (NSMutableArray *)masonryViewArray {
    if (!_masonryViewArray) {
        _masonryViewArray = [NSMutableArray array];
    }
    return _masonryViewArray;
}

- (UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.backgroundColor = [UIColor clearColor];
        _headerImageView.layer.cornerRadius = _headerImageViewWidth / 2;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.image = [UIImage imageNamed:@"avater"];
    }
    return _headerImageView;
}



-(UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorColor:[UIColor hexStringToColor:@"#e2e2e2"]];
        _tableView.tableHeaderView = self.headView;
        self.tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:@"ScoreEncourageCell" bundle:nil] forCellReuseIdentifier:@"ScoreEncourageCell"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        }
    }
    return _tableView;
}

-(NSArray *)sourceArr{
    
    return @[@{@"image":@"mine_icon_1",@"title":@"分享给好友"},
             @{@"image":@"mine_icon_2",@"title":@"短信记录"},
             @{@"image":@"mine_icon_3",@"title":@"我要推广"},
             @{@"image":@"mine_icon_4",@"title":@"参数设置"},
             @{@"image":@"mine_icon_5",@"title":@"清理通讯录"},
             @{@"image":@"mine_icon_6",@"title":@"意见反馈"},
             @{@"image":@"mine_icon_7",@"title":@"联系我们"}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 8.f;
    } else {
        return 8.f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.sourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        
        UILabel *flagLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        flagLabel.text = @"";
        flagLabel.font = [UIFont systemFontOfSize:12];
        flagLabel.textColor = [UIColor hexStringToColor:@"#999999"];
        [cell.contentView addSubview:flagLabel];
        flagLabel.tag = 10001;
        [flagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.right.equalTo(cell.contentView.mas_right).offset = -10;
        }];
    }
    
    UILabel *label = [cell.contentView viewWithTag:10001];
    
    if([[self sourceArr][indexPath.row][@"title"] isEqualToString:@"分享给好友"]){
        label.hidden = NO;
        label.text = @"";
        label.textColor = [UIColor hexStringToColor:@"#999999"];
    } else if ([[self sourceArr][indexPath.row][@"title"] isEqualToString:@"我要推广"]) {
        label.hidden = NO;
        label.text = @"推广我的产品/服务";
        label.textColor = [UIColor hexStringToColor:@"#999999"];
        
    } else if ([[self sourceArr][indexPath.row][@"title"] isEqualToString:@"清理通讯录"]) {
        label.hidden = NO;
        label.text = @"清理导入的通讯录";
        label.textColor = [UIColor hexStringToColor:@"#999999"];
        
    } else {
        label.hidden = YES;
    }
    
    
    cell.imageView.image = [UIImage imageNamed:[self sourceArr][indexPath.row][@"image"]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor hexStringToColor:@"#333333"];
    cell.textLabel.text = [self sourceArr][indexPath.row][@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int num = (int)indexPath.row;
    
    switch (num) {
        case 0://分享给好友
            
        {
            if (_shareModel) {
                [self share];
            }else
            {
                [self requestDoShare];
            }
        }
            break;
        case 1:
        {
            MessageListVC *messageListVC = [[MessageListVC alloc] init];
            messageListVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:messageListVC animated:YES];
        }
            break;
        case 2://我要推广
        {
            if (SWTUtils.isSetting) {
                LoginVC *login = [[LoginVC alloc] init];
                BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
                [self presentViewController:navigationController animated:YES completion:nil];
                return;
            }
            if (SWTUtils.isLoginV) {
                WantToPromoteVC *wantToPromoteVC = [[WantToPromoteVC alloc] init];
                wantToPromoteVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wantToPromoteVC animated:YES];
            }else
            {
                 [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
            }
        }
           
            break;
        case 3:
        {
            ParameterSettingVC *parameterSettingVC = [[ParameterSettingVC alloc] init];
            parameterSettingVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:parameterSettingVC animated:YES];
        }
            break;
        case 4://清理通讯录
        {
            [self cleanContect];
           
        }
            break;
        case 5://意见反馈
        {
            FeedBackVC *feedbackvc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil] instantiateViewControllerWithIdentifier:@"feedback"];
            feedbackvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:feedbackvc animated:YES];
        }

            break;
        case 6:
        {
            ContactUsVC *contactUsVC = [[ContactUsVC alloc] init];
            contactUsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contactUsVC animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(void)request{
    
    SWTProgressHUD *hud = nil;
    if (self.tableView.hidden == YES) {
        hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中.."];
    }
    
    
    //如果获取成功，保存整个登录对象
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    NSString *strUrl = @"api/Customer/WhiteLogin";
    NSString *mobile = [userDefaults objectForKey:@"Mobile"];
    if(mobile&&![mobile isEqualToString:@""]){
//    paramesDic[@"mobile"] = @"15838113123";
//    paramesDic[@"password"] = @"123456";
        paramesDic[@"mobile"] = [userDefaults objectForKey:@"Mobile"];
        paramesDic[@"password"] = [userDefaults objectForKey:@"Password"];
        strUrl = @"api/Customer/LoginByMobile";
    }
    
    
    [[RequestInstance shareInstance] POST:GETAPIURL(strUrl) parameters:paramesDic usableStatus:^(NSDictionary *dict) {
        
        NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithDictionary:dict[@"data"]];
        
        if (hud) {
            [hud hideAnimated:YES];
        }
        self.tableView.hidden = NO;
        [self.tableView.mj_header endRefreshing];
        
        self.isLoadedData = YES;
        
        NSString *strPsd = [userDefaults objectForKey:@"Password"];
        if (strPsd&&![strPsd isEqualToString:@""]) {
            [dictData setValue:strPsd forKey:@"Password"];
        }else
        {
            [dictData setValue:nil forKey:@"Password"];
        }
        
        
        _userModel = [[UserEnertyModel alloc]initWithDictionary:dictData error:nil];
        
        _userModel.Password = [userDefaults objectForKey:@"Password"];
        
        if(_userModel.Mobile && ![_userModel.Mobile isEqualToString:@""]){
            self.btnLoginOut.hidden = NO;
            self.mineUserYype.hidden = NO;
            self.mineUserName.text = _userModel.Nickname;
            self.mineUserMobile.text = _userModel.Mobile;
            self.jiansuo_Num.text = _userModel.QueryCnt;
            self.tianjia_Num.text = _userModel.AddCnt;
            self.tuiguang_Num.text = _userModel.ShareCnt;
            self.mineUserYype.text = _userModel.Type;
            self.headerImageView.image = [UIImage imageNamed:@"image_login_login"];
        }else{
            self.btnLoginOut.hidden = YES;
            self.mineUserYype.hidden = YES;
            self.mineUserName.text = @"未注册";
            self.mineUserMobile.text = @"登录/注册";
            self.jiansuo_Num.text = @"0个";
            self.tianjia_Num.text = @"0个";
            self.tuiguang_Num.text = @"0个";
            self.headerImageView.image = [UIImage imageNamed:@"avater"];
        }
        
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
        
        
        
        [self.tableView reloadData];
        [self dismissErrorDataView];
        [self dismissNoNetworkView];
        
    } unusableStatus:^(NSDictionary *dic) {
        if (hud) {
            [hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        
        if (!self.isLoadedData || self.tableView.hidden) {
            [self showErrorDataView];
        }else{
            [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        }
        
    } error:^(NSError *error) {
        if (hud) {
            [hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        
        if (!self.isLoadedData ||self.tableView.hidden) {
            
            [self showErrorDataView];
        }else{
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络获取失败"];
        }
        
    }];
    
}

//获取设置
- (void)requestAppleVerifyData{
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/AppleVerify") parameters:nil usableStatus:^(NSDictionary *dic) {
        [[NSUserDefaults standardUserDefaults] setObject:dic[@"data"] forKey:@"appleVerify"];
    } unusableStatus:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
}
#pragma mark 退出登录
- (void)loginOut{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否退出该用户？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 退出登录成功后发一个退出登录成功通知
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Mobile"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"IsAuth"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUTSUCCESS" object:nil userInfo:nil];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
   
}

#pragma mark 登录
- (void)login{
    if (!SWTUtils.isLogin) {
        LoginVC *login = [[LoginVC alloc] init];
        BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark 清理通讯录
- (void)cleanContect
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您确定要删除从超级名录里添加的联系人吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         [self requestContactAuthorAfterSystemVersion9];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark 分享

-(void)requestDoShare{
    
    SWTProgressHUD *hud = nil;
    hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中.."];
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/ShareSetting") parameters:nil usableStatus:^(NSDictionary *dict) {
        
        NSDictionary *dictData = dict[@"data"];
        
        if (hud) {
            [hud hideAnimated:YES];
        }
        
        _shareModel = [[SYBShareModel alloc]initWithDictionary:dictData error:nil];
        [self share];
    } unusableStatus:^(NSDictionary *dic) {
        if (hud) {
            [hud hideAnimated:YES];
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        
    } error:^(NSError *error) {
        if (hud) {
            [hud hideAnimated:YES];
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络获取失败"];
        
    }];
    
}

- (void)share{
    SYBShareView *shareView = [SYBShareView shareViewWithModel:_shareModel];
    shareView.rootViewController = self;
    [shareView show];
}

-(void)hideTableView{
    [self setUserData];
}

#pragma mark 删除通讯录

- (void)deleteLocalMarkSuccess{
    
    //获取没有经过排序的联系人模型
    [PPGetAddressBook getOriginalAddressBook:^(NSArray<PPPersonModel *> *addressBookArray) {
        //addressBookArray:原始顺序的联系人模型数组
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"正在删除超级名录通讯"];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            ABAddressBookRef addressBook = ABAddressBookCreate();
            //取得通讯录中所有人员记录
            CFArrayRef allPeople= ABAddressBookCopyArrayOfAllPeople(addressBook);
            // self.allPerson=(__bridge NSMutableArray *)allPeople;
            NSArray* allPersonArray = [NSMutableArray array];
            allPersonArray = (__bridge NSMutableArray*)allPeople;
            //释放资源
            CFRelease(allPeople);
            
            
            //delete all
            int count = (int)allPersonArray.count;
            for(int i = 0; i < count; ++i){
                ABRecordRef record = (__bridge ABRecordRef)allPersonArray[i];
                NSString *firstName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
                //这里是特殊情况的比较号码并删除，正常是比较姓名即可
                if ([firstName containsString:@"A名录_"])
                {
                    ABAddressBookRemoveRecord(addressBook, record , NULL);
                    NSLog(@"已经删除%@",addressBookArray[i].name);
                }
                
            }
            
            ABAddressBookSave(addressBook, nil);
            CFRelease(addressBook);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_hud) {
                    [_hud hideAnimated:YES];
                }
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"删除成功"];
            });
        });
    } authorizationFailure:^{
        [self showAlertViewAboutNotAuthorAccessContact];
    }];
    
    
}
//请求通讯录权限
#pragma mark 请求通讯录权限
- (void)requestContactAuthorAfterSystemVersion9{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                NSLog(@"授权失败");
            }else {
                NSLog(@"成功授权");
            }
        }];
    }
    else if(status == CNAuthorizationStatusRestricted)
    {
        [self showAlertViewAboutNotAuthorAccessContact];
    }
    else if (status == CNAuthorizationStatusDenied)
    {
        [self showAlertViewAboutNotAuthorAccessContact];
    }
    else if (status == CNAuthorizationStatusAuthorized)//已经授权
    {
        //有通讯录权限-- 进行下一步操作
        [self deleteLocalMarkSuccess];
    }
    
}

//提示没有通讯录权限
- (void)showAlertViewAboutNotAuthorAccessContact{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"请授权通讯录权限"
                                          message:@"请在iPhone的\"设置-隐私-通讯录\"选项中,允许花解解访问你的通讯录"
                                          preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


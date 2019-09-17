//
//  HomePageVC.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "HomePageVC.h"
#import "Masonry.h"
#import "SDCycleScrollView.h"
#import "UIView+Frame.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "NSString+Size.h"
#import "HomePageCell.h"
#import "AdvertisementVC.h"
#import "SWTProgressHUD.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "JPUSHService.h"
#import "SWTCustomNavBar.h"
#import "UIViewController+Refresh.h"
#import "LoginVC.h"
#import "BaseNavigationController.h"
#import "SWTUtils.h"
#import "SWTWebViewController.h"
#import "SDLAreaSelectView.h"
#import "UIView+Frame.h"
#import "HomeIndustryVC.h"
#import "HomeQueryModel.h"
#import "PPGetAddressBook.h"
#import "HomeSendMessageVC.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "SWTLocationManager.h"

//高德地图时间设置
#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

@interface HomePageVC ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate,
                            AdvertisementVCDelegate,
                            SDLAreaSelectViewDelegate,
                            HomeIndustryVCDelegate,
                            AMapLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *suspensionView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *dataAddContactsArr;

//普通的等待框
@property (nonatomic, strong) SWTProgressHUD *hud;
//添加通讯录时候的等待框  因为需要重新赋值内容 所以重新创建了一个
@property (nonatomic, strong) SWTProgressHUD *addHUD;


// 轮播图 和 保存的数组
@property (nonatomic, strong)SDCycleScrollView *bannerView;
@property (nonatomic, strong)NSArray *bannerList;
//自定义状态栏
@property (nonatomic, strong) SWTCustomNavBar *customNavBar;

//行业、地址选择、搜索 添加通讯录、 发送短信 按钮
@property (nonatomic, strong) UIButton *btnIndustry;
@property (nonatomic, strong) UIButton *btnSelectAddress;

//地址选择框
@property (nonatomic,strong)UIView *attributesView;
@property (nonatomic,strong)SDLAreaSelectView *sdlAreaSeleView;

//存储行业、地址按钮水平均分布局数组
@property (nonatomic, strong) NSMutableArray *masonryViewArray;

//地址选择
@property (nonatomic, strong)NSArray *addressList;
@property (nonatomic, copy) NSString *nProvincename;
@property (nonatomic, copy) NSString *nCityname;
@property (nonatomic, copy) NSString *oProvincename;
@property (nonatomic, copy) NSString *oCityname;
@property (nonatomic,copy) NSString *strCategory;
@property (nonatomic,copy) NSString *strCategoryold;

@property (nonatomic, strong) MJRefreshAutoNormalFooter *footer;

//定位
@property (nonatomic, strong) AMapLocationManager *locationManager;

//分页
@property (nonatomic,assign) int p;
//分页提示语
@property (nonatomic,strong) UILabel *labTiShi;
//悬浮view
@property (nonatomic,strong) UILabel *labSuspensionTiShi;
@end

static NSString * HomePageCellID = @"HomePageCellID";

@implementation HomePageVC{
    BOOL _isLightStatusBar; // 是否是白色状态条， YES:是  NO:不是
    CGFloat _oldOffsetY;
    BOOL _isLoadedData; // 标识数据是否加载过  YES:加载过  NO：没有加载过
    BOOL _isNew;
    CGFloat _topViewHeight;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];                                              
    // 设置广告
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"advertisementImg"] != nil) {
        AdvertisementVC *advertisemengvc = [[AdvertisementVC alloc]init];
        advertisemengvc.delegate = self;
        advertisemengvc.dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"advertDict"];
        [self presentViewController:advertisemengvc animated:NO completion:nil];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.fd_prefersNavigationBarHidden = YES;
    _isLightStatusBar = YES;
    _oldOffsetY = 0;
    _isNew = true;
    _topViewHeight = 0;
    self.nProvincename = @"北京";
    self.nCityname = @"北京";
    self.oProvincename = @"";
    self.oCityname = @"";
    self.p = 0;
    self.strCategory = @"KTV唱吧/酒吧";
    self.strCategoryold = @"";
    [self customSetupView];
    self.tableView.hidden = YES;
    [self setupRefresh:self.tableView hasHeaderRefresh:NO hasFooterRefresh:YES withPage:0 ForSelector:@selector(requestQueryData)];
    
    self.footer = (MJRefreshAutoNormalFooter *)self.tableView.mj_footer;
    [self registerNotification];
    
    if ([SWTReachability shareInstance].isNetworkReachable) { // 有网络
        
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        
        [self requestData];
    
    } else { // 无网络
        
    }
    
//    if ([SWTLocationManager determineWhetherTheAPPOpensTheLocation]) {
//
//    }else
//    {
//
//    }
    
    [self getLocation];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestAppleVerifyData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)networkReachability{
    if (!_isLoadedData) {
        [self dismissErrorDataView];
        [self dismissNoNetworkView];
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        [self requestData];
    }
}

- (void)networkNotReachability{
    self.tableView.hidden = YES ;
    [self showNoNetworkView];
}

#pragma mark - request data 请求首页轮播图数据
//获取首页轮播图
- (void)requestData{
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Banners") parameters:nil usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        _bannerList = dic[@"data"];
        [self resetDataWithDic:dic[@"data"]];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!_isLoadedData) {
            [self showErrorDataView];
        } else {
            [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        }
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!_isLoadedData) {
            [self showErrorDataView];
        } else {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
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

- (void)resetDataWithDic:(NSDictionary *)dict{
    
    _isLoadedData = YES;
    NSMutableArray *mutableimageArr = [NSMutableArray array];
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NSDictionary *dic in _bannerList) {

        [mutableimageArr addObject:dic[@"Picture"]];

        [titleArr addObject:dic[@"Name"]];
    }
    NSArray *imagesURLStrings = mutableimageArr;
    self.bannerView.imageURLStringsGroup = imagesURLStrings;
    
    [self.tableView reloadData];

    self.tableView.hidden = NO;
    
}

- (void)reRequestData{
    [self dismissErrorDataView];
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"数据加载..."];
    [self requestData];
}


#pragma mark 请求省市区地址数据
//省市区地址数据
- (void)requestAddressData{
    
    if (self.addressList) {
        [self areaSelectAction];
    }else
    {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"数据加载..."];
        [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/Provices") parameters:nil usableStatus:^(NSDictionary *dic) {
            if (_hud) {
                [_hud hideAnimated:YES];
            }
            self.addressList = dic[@"data"];
            [self areaSelectAction];
        } unusableStatus:^(NSDictionary *dic) {
            if (_hud) {
                [_hud hideAnimated:YES];
            }
            [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        } error:^(NSError *error) {
            if (_hud) {
                [_hud hideAnimated:YES];
            }
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        }];
    }
    
    
}

#pragma mark 查询搜索结果
//查询搜索结果
- (void)requestQueryData{

    if (!_isNew) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"数据持续更新中，敬请期待"];
        [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"category"] = self.strCategory;
    paramesDic[@"province"] = self.nProvincename;
    paramesDic[@"city"] = self.nCityname;
    paramesDic[@"p"] = @(self.p);
    [self updateFuncTemplate:self.tableView api:@"api/Record/Query" postMixin:paramesDic resultArray:self.dataArr resultBlock:^(NSDictionary *dic) {
        NSArray *listArr = dic[@"data"][@"data"];
        self.labTiShi.text = dic[@"data"][@"message"];
        self.labSuspensionTiShi.text = dic[@"data"][@"message"];
        if ([dic[@"data"][@"lastpage"] intValue] == 1) {
            _isNew = false;
            [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
        }
        if (listArr.count) {
            self.p++;
            [self.dataArr removeAllObjects];
            for (NSDictionary *tempDic in listArr) {
                HomeQueryModel *model = [[HomeQueryModel alloc] initWithDictionary:tempDic error:nil];
                [self.dataArr addObject:model];
            }
            [self.footer setTitle:@"加载完毕" forState:MJRefreshStateIdle];
            [self.tableView reloadData];
        }else
        {
            if (self.p == 0) {
                [self.dataArr removeAllObjects];
                [self.tableView reloadData];
                [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
            }else
            {
                [self.footer setTitle:@"已全部加载完毕" forState:MJRefreshStateIdle];
            }
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
    
}

- (void)requestBtnQueryData{
    
    if (!_isNew) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"数据持续更新中，敬请期待"];
        [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    
    if (![self.strCategory isEqualToString:self.strCategoryold]) {
        self.p = 0;
        self.strCategoryold = self.strCategory;
    }
    
    if (![self.nProvincename isEqualToString:self.oProvincename]) {
        self.p = 0;
        self.oProvincename = self.nProvincename;
    }
    
    if (![self.nCityname isEqualToString:self.oCityname]) {
        self.p = 0;
        self.oCityname = self.nCityname;
    }
    
    NSString *message = [NSString stringWithFormat:@"正在检索[%@]",self.strCategory];
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:message];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"category"] = self.strCategory;
    paramesDic[@"province"] = self.nProvincename;
    paramesDic[@"city"] = self.nCityname;
    paramesDic[@"p"] = @(self.p);
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/Query") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        NSArray *listArr = dic[@"data"][@"data"];
        self.labTiShi.text = dic[@"data"][@"message"];
        self.labSuspensionTiShi.text = dic[@"data"][@"message"];
        if ([dic[@"data"][@"lastpage"] intValue] == 1) {
            _isNew = false;
            [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
        }
        
        if (listArr.count) {
            self.p++;
            [self.dataArr removeAllObjects];
            for (NSDictionary *tempDic in listArr) {
                HomeQueryModel *model = [[HomeQueryModel alloc] initWithDictionary:tempDic error:nil];
                [self.dataArr addObject:model];
            }
            [self.footer setTitle:@"数据加载完毕" forState:MJRefreshStateIdle];
        }else
        {
            if (self.p == 0) {
                [self.dataArr removeAllObjects];
                [self.footer setTitle:@"数据持续更新中，敬请期待" forState:MJRefreshStateIdle];
            }else
            {
                 [self.footer setTitle:@"已全部加载完毕" forState:MJRefreshStateIdle];
            }
        }
    
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!_isLoadedData) {
            [self showErrorDataView];
        } else {
            [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
        }
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!_isLoadedData) {
            [self showErrorDataView];
        } else {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        }
    }];
}


- (void)requestQueryCountData
{
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍后.."];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"count"] = @(self.dataAddContactsArr.count);
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/ExportToMobile") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        
        [self addConacts];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
         [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
    }];
}

#pragma mark - private

- (void)customSetupView{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.customNavBar];
    [self.view addSubview:self.suspensionView];
    self.suspensionView.hidden = YES;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.customNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kNavigationBarHeight + kStatusBarHeight);
    }];
    
    [self.suspensionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBar.mas_bottom);
        make.height.mas_equalTo(50.0f);
    }];
}

- (void)clearRightBarButton{
    self.navigationItem.rightBarButtonItem = nil;
}
- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LOGINSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:@"LOGOUTSUCCESS" object:nil];
    
}

// 登录成功
- (void)loginSuccess{
    
}

// 退出登录
- (void)logoutSuccess{
    
}

- (void)showNoNetworkView{
    [self.view addSubview:self.noNetworkView];
    
    [self.noNetworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view); 
    }];
}

- (void)showErrorDataView{
    [self.view addSubview:self.errorDataView];
    
    [self.errorDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view); 
    }];
}

#pragma mark - lazy load 

- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kTabbarHeight, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            if ([_tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        [_tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:HomePageCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        
        CGFloat bannerViewHeight;
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        //bannerView lazy load 添加轮播图
        [_tableHeaderView addSubview:self.bannerView];
        
        bannerViewHeight = CGRectGetMaxY(self.bannerView.frame);
        //添加行业、地址筛选、搜索按钮
        //1.搜索按钮
        CGFloat padding = 10.0f;
        CGFloat vQueryHeight = 40.0f;
        UIView *vQueryBg = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bannerView.frame)+padding, kScreenWidth, vQueryHeight+padding)];
        [_tableHeaderView addSubview:vQueryBg];
        
        UIButton *btnQuery = [UIButton buttonWithType:UIButtonTypeCustom];
        btnQuery.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnQuery setTitle:@"搜" forState:UIControlStateNormal];
        [btnQuery setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnQuery addTarget:self action:@selector(requestBtnQueryData) forControlEvents:UIControlEventTouchUpInside];
        btnQuery.titleLabel.font = FONT(16);
        btnQuery.layer.cornerRadius = 4.0;
        [vQueryBg addSubview:btnQuery];
        [btnQuery mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vQueryBg);
            make.right.equalTo(vQueryBg).offset(-padding);
            make.height.with.width.mas_equalTo(vQueryHeight);
        }];
        _topViewHeight = bannerViewHeight+vQueryHeight+2*padding-(kNavigationBarHeight + kStatusBarHeight);
        
        UIView *vQuery = [[UIView alloc] init];
        vQuery.userInteractionEnabled = YES;
        
        [vQueryBg addSubview:vQuery];
        
        [vQuery mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vQueryBg);
            make.right.equalTo(btnQuery.mas_left);
            make.top.equalTo(vQueryBg);
            make.height.mas_equalTo(vQueryHeight);
        }];
        
        UIButton *industryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [industryBtn setTitle:self.strCategory forState:UIControlStateNormal];
        [industryBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        industryBtn.titleLabel.font = FONT(14);
        industryBtn.layer.cornerRadius = 4.0;
        industryBtn.layer.borderWidth  = 0.5;
        industryBtn.layer.borderColor = [UIColor hexStringToColor:@"#e1e2e1"].CGColor;
        industryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [industryBtn addTarget:self action:@selector(toHomeIndustry) forControlEvents:UIControlEventTouchUpInside];
        industryBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 2);
        

        self.btnIndustry = industryBtn;
        [self.masonryViewArray addObject:industryBtn];
        
        UIButton *addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressBtn setTitle:[NSString stringWithFormat:@"%@-%@",self.nProvincename,self.nCityname] forState:UIControlStateNormal];
        [addressBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        addressBtn.titleLabel.font = FONT(14);
        addressBtn.layer.cornerRadius = 4.0;
        addressBtn.layer.borderWidth  = 0.5;
        addressBtn.layer.borderColor = [UIColor hexStringToColor:@"#e1e2e1"].CGColor;
        addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addressBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 2);
        [addressBtn addTarget:self action:@selector(requestAddressData) forControlEvents:UIControlEventTouchUpInside];
        self.btnSelectAddress = addressBtn;
        [self.masonryViewArray addObject:addressBtn];
        
        [vQuery addSubview:industryBtn];
        [vQuery addSubview:addressBtn];
        // 实现masonry水平固定间隔方法
        [self.masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:10 tailSpacing:10];
        
        // 设置array的垂直方向的约束
        [self.masonryViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(vQueryHeight);
            make.top.bottom.mas_equalTo(vQuery);
            
        }];
        //箭头适配
        UIImageView *industryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-down-Menu01"]];
        [vQuery addSubview:industryImg];
        [industryImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(vQuery);
            make.right.equalTo(industryBtn).mas_offset(-6);
        }];
        
        UIImageView *addressImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-down-Menu01"]];
        [vQuery addSubview:addressImg];
        [addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(vQuery);
            make.right.equalTo(addressBtn).mas_offset(-6);
        }];
        
        
        //添加发短信、拨打电话功能
        CGFloat vContactHeight = 40.0f;
        UIView *vContactBg = [[UIView alloc] initWithFrame:CGRectMake(0, bannerViewHeight+vQueryHeight+2*padding, kScreenWidth, vContactHeight+padding)];
        vContactBg.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [_tableHeaderView addSubview:vContactBg];
        
        UIButton *btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSendMessage.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnSendMessage setTitle:@"群发短信" forState:UIControlStateNormal];
        [btnSendMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSendMessage addTarget:self action:@selector(toHomeSendMessage) forControlEvents:UIControlEventTouchUpInside];
        btnSendMessage.titleLabel.font = FONT(13);
        btnSendMessage.layer.cornerRadius = 4.0;
        [vContactBg addSubview:btnSendMessage];
        [btnSendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vContactBg).mas_offset(7);
            make.right.equalTo(vContactBg).offset(-padding);
            make.bottom.equalTo(vContactBg).mas_offset(-7);
            make.width.mas_equalTo(70);
        }];
        
        UIButton *btnAddContact = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddContact.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnAddContact setTitle:@"添加到通讯录" forState:UIControlStateNormal];
        [btnAddContact setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAddContact addTarget:self action:@selector(requestContactAuthorAfterSystemVersion9) forControlEvents:UIControlEventTouchUpInside];
        btnAddContact.titleLabel.font = FONT(13);
        btnAddContact.layer.cornerRadius = 4.0;
        [vContactBg addSubview:btnAddContact];
        [btnAddContact mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vContactBg).mas_offset(7);
            make.right.equalTo(btnSendMessage.mas_left).offset(-5);
            make.bottom.equalTo(vContactBg).mas_offset(-7);
            make.width.mas_equalTo(90);
        }];
        
        UILabel *labTiShi = [[UILabel alloc] init];
        labTiShi.textColor = [UIColor hexStringToColor:@"#666666"];
        labTiShi.font = FONT(12);
        labTiShi.text = @"暂无数据";
        self.labTiShi = labTiShi;
        [vContactBg addSubview:labTiShi];
        [labTiShi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vContactBg).mas_offset(10);
            make.right.equalTo(btnAddContact.mas_left).offset(5);
            make.centerY.equalTo(vContactBg);
        }];
        
        _tableHeaderView.height = CGRectGetMaxY(vContactBg.frame)+padding;
    }
    return _tableHeaderView;
}

- (UIView *)suspensionView
{
    if (!_suspensionView) {
        //添加发短信、拨打电话功能
        CGFloat vContactHeight = 50.0f;
        CGFloat padding = 10;
        _suspensionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _suspensionView.backgroundColor = [UIColor whiteColor];
        UIView *vContactBg = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.width, vContactHeight)];
        vContactBg.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [_suspensionView addSubview:vContactBg];
        
        UIButton *btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSendMessage.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnSendMessage setTitle:@"群发短信" forState:UIControlStateNormal];
        [btnSendMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSendMessage addTarget:self action:@selector(toHomeSendMessage) forControlEvents:UIControlEventTouchUpInside];
        btnSendMessage.titleLabel.font = FONT(13);
        btnSendMessage.layer.cornerRadius = 4.0;
        [vContactBg addSubview:btnSendMessage];
        [btnSendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vContactBg).mas_offset(7);
            make.right.equalTo(vContactBg).offset(-padding);
            make.bottom.equalTo(vContactBg).mas_offset(-7);
            make.width.mas_equalTo(70);
        }];
        
        UIButton *btnAddContact = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddContact.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnAddContact setTitle:@"添加到通讯录" forState:UIControlStateNormal];
        [btnAddContact setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAddContact addTarget:self action:@selector(requestContactAuthorAfterSystemVersion9) forControlEvents:UIControlEventTouchUpInside];
        btnAddContact.titleLabel.font = FONT(13);
        btnAddContact.layer.cornerRadius = 4.0;
        [vContactBg addSubview:btnAddContact];
        [btnAddContact mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(vContactBg).mas_offset(7);
            make.right.equalTo(btnSendMessage.mas_left).offset(-5);
            make.bottom.equalTo(vContactBg).mas_offset(-7);
            make.width.mas_equalTo(90);
        }];
        
        UILabel *labTiShi = [[UILabel alloc] init];
        labTiShi.textColor = [UIColor hexStringToColor:@"#666666"];
        labTiShi.font = FONT(12);
        labTiShi.text = @"暂无数据";
        self.labSuspensionTiShi = labTiShi;
        [vContactBg addSubview:labTiShi];
        [labTiShi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vContactBg).mas_offset(10);
            make.right.equalTo(btnAddContact.mas_left).offset(5);
            make.centerY.equalTo(vContactBg);
        }];
    }
    return _suspensionView;
}

#pragma mark 选择行业
-(void)toHomeIndustry{
   
    HomeIndustryVC *homeIndustryVC = [[HomeIndustryVC alloc] init];
    homeIndustryVC.delegate = self;
    homeIndustryVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:homeIndustryVC animated:YES];
    
}


#pragma mark 群发短信
-(void)toHomeSendMessage{
    
    if (SWTUtils.isSetting) {
        LoginVC *login = [[LoginVC alloc] init];
        BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    }
    
    if(SWTUtils.isLoginV){
        if (self.dataArr.count>0) {
            NSString *message = @"";
            for (int i = 0; i<self.dataArr.count; i++) {
                HomeQueryModel *model = self.dataArr[i];
                
                NSArray *array = [model.tel componentsSeparatedByString:@","];
                for (NSString *str in array) {
                    NSArray *strArray = [str componentsSeparatedByString:@" "];
                    for (NSString *tel in strArray) {
                        
                        if (tel && tel.length==11&&[tel hasPrefix:@"1"]) {
                            if ([message isEqualToString:@""]) {
                                message = tel;
                            }else
                            {
                                message = [NSString stringWithFormat:@"%@,%@",message,tel];
                            }
                        }
                        
                    }
                }
            }
            if (![message isEqualToString:@""]) {
                HomeSendMessageVC *homeSendMessageVC = [[HomeSendMessageVC alloc] init];
                [homeSendMessageVC setMessage:message];
                homeSendMessageVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:homeSendMessageVC animated:YES];
            }else
            {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"暂无可使用号码"];
            }
        }
    }else
    {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
    }
    
    
}




-(SDCycleScrollView *)bannerView{
    
    if (!_bannerView) {
        
        CGFloat bannerW = self.view.width;
        CGFloat bannerH = bannerW * 400 / 750;
        _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0,0,bannerW, bannerH) delegate:self placeholderImage:nil];
        
        _bannerView.placeholderImage = [UIImage imageNamed:@"home_banner_icon"];
        
        _bannerView.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
        
        _bannerView.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
        
        _bannerView.pageControlDotSize = CGSizeMake(7, 7);
        
        _bannerView.autoScrollTimeInterval = 3.0f;
    }
    return _bannerView;
}

- (NSMutableArray *)masonryViewArray {
    if (!_masonryViewArray) {
        _masonryViewArray = [NSMutableArray array];
    }
    return _masonryViewArray;
}

- (SWTCustomNavBar *)customNavBar{
    if (!_customNavBar) {
        _customNavBar = [[SWTCustomNavBar alloc] init];
        [_customNavBar setBackgroundColor:[UIColor hexStringToColor:mColor_TopTarBg]];
        _customNavBar.title = @"首页";
        _customNavBar.titleColor = [UIColor whiteColor];
        _customNavBar.titleFont = [UIFont systemFontOfSize:18];
        _customNavBar.alpha = 0;
    }
    return _customNavBar;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (NSMutableArray *)dataAddContactsArr{
    if (!_dataAddContactsArr) {
        _dataAddContactsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataAddContactsArr;
}

#pragma mark UITableViewDataSource && UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ShowOrigin"]&&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowOrigin"] isEqualToString:@"1"]) {
        return 60;
    }else
    {
        return 44;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:HomePageCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HomeQueryModel *model = _dataArr[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeQueryModel *model = self.dataArr[indexPath.row];
    // 方法4
    /*
     iOS8以后出现了UIAlertController视图控制器，通过设置UIAlertController的style属性来控制是alertview还是actionsheet
     */
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:@"拨打电话" preferredStyle:UIAlertControllerStyleActionSheet];
    // 响应方法-取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消按钮");
    }];
    
    
    NSArray *array = [model.tel componentsSeparatedByString:@","];
    for (NSString *str in array) {
        NSArray *strArray = [str componentsSeparatedByString:@" "];
        for (NSString *tel in strArray) {
            // 响应方法-电话
            UIAlertAction *takeAction = [UIAlertAction actionWithTitle:tel style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *newPhoneNo = [[action.title componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString: @""];
                NSString *phoneCall = [NSString stringWithFormat:@"tel://%@",newPhoneNo];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneCall]];
            }];
            [takeAction setValue:[UIColor hexStringToColor:@"#666666"] forKey:@"titleTextColor"];
            [actionSheetController addAction:takeAction];
        }
    }
    
    // 添加响应方式
    [actionSheetController addAction:cancelAction];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 显示
        [self presentViewController:actionSheetController animated:YES completion:nil];
    });
    
}
#pragma  mark ------------屏幕滚动监听  start------------

-  (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffSetY = self.tableView.contentOffset.y;

    _oldOffsetY = contentOffSetY;
    
    CGFloat bannerH = self.view.bounds.size.width * 400 / 750 - 20;
    if (contentOffSetY > bannerH) {
        self.customNavBar.alpha = 1;
        if (_isLightStatusBar) {
            _isLightStatusBar = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
        }
    } else {
        CGFloat alpha = contentOffSetY / bannerH;
        self.customNavBar.alpha = alpha;
        if (!_isLightStatusBar) {
            _isLightStatusBar = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    if (contentOffSetY>_topViewHeight) {
        self.suspensionView.hidden = NO;
    }else
    {
         self.suspensionView.hidden = YES;
    }
    
}

#pragma  mark ------------屏幕滚动监听  end------------

#pragma mark - SDCycleScrollViewDelegate 顶部广告轮播图

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    if ([[_bannerList[index] objectForKey:@"IsNavigate"] intValue] != 0 && ![_bannerList[index][@"Url"] isEqualToString:@""]) {
        SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
        webViewVC.urlString = _bannerList[index][@"Url"];
        if ([_bannerList[index][@"Name"] isEqualToString:@""]) {
            webViewVC.titleString = @"广告";
        }else{
            webViewVC.titleString = _bannerList[index][@"Name"];
        }
        webViewVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
    
}
#pragma  mark ------------开屏广告跳转  start------------

-(void)wentanywhere:(UIViewController *)contrl data:(NSDictionary *)dic{
    
    if ([[dic objectForKey:@"IsRedirect"] intValue] == 1) {
        [contrl dismissViewControllerAnimated:NO completion:nil];
        SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
        webViewVC.titleString = dic[@"Text"];
        webViewVC.urlString = dic[@"Url"];
        webViewVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
}

#pragma  mark ------------开屏广告跳转  end------------

#pragma  mark ------------选择地址页面  start------------
//弹出地址选择框
-(void)areaSelectAction{
    //蒙版
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    maskView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.56];
    self.attributesView = maskView;
    [[[UIApplication sharedApplication].delegate window] addSubview:self.attributesView];
    
    UITapGestureRecognizer *tapcanel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectviewDismissed)];
    [maskView addGestureRecognizer:tapcanel];
    
    _sdlAreaSeleView =  [[SDLAreaSelectView alloc] init];
    _sdlAreaSeleView.delegate = self;
    [_sdlAreaSeleView setName:_nProvincename cityName:_nCityname];
    [_sdlAreaSeleView setAddressList:self.addressList];
    [[[UIApplication sharedApplication].delegate window] addSubview:_sdlAreaSeleView];
    [UIView animateWithDuration:0.25 animations:^{
        _sdlAreaSeleView.frame = CGRectMake(0, kScreenHeight/3, kScreenWidth,kScreenHeight*2/3);
    }];
}
//选择地址结果监听
-(void)finishedSelecteWith:(NSString *)areaShowValue areaData:(NSDictionary *)areaDict{
    [self.btnSelectAddress setTitle:areaShowValue forState:UIControlStateNormal];
    self.nProvincename = areaDict[@"currentProvinceName"];
    self.nCityname = areaDict[@"currentCityName"];
    
    if (![self.nProvincename isEqualToString:self.oProvincename]) {
        _isNew = true;
        self.p = 0;
    }
    
    if (![self.nCityname isEqualToString:self.oCityname]) {
        _isNew = true;
        self.p = 0;
    }
    [self selectviewDismissed];
}
//监听地址弹出框消失
-(void)selectviewDismissed{
    
    [UIView animateWithDuration:0.25f animations:^{
        
        _sdlAreaSeleView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight*2/3);
    } completion:^(BOOL finished) {
        [_sdlAreaSeleView removeFromSuperview];
        [self.attributesView removeFromSuperview];
        self.attributesView = nil;
    }];
}
#pragma  mark ------------选择地址页面  end------------

#pragma  mark ------------行业选择  start------------

- (void)searchResult:(NSString *)sResult
{
    [self.btnIndustry setTitle:sResult forState:UIControlStateNormal];
    self.strCategory = sResult;
    
    if (![self.strCategory isEqualToString:self.strCategoryold]) {
        _isNew = true;
        self.p = 0;
    }
}

#pragma  mark ------------行业选择  end------------



#pragma  mark ------------添加通讯录  start------------
//获取全部通讯录
- (void)getAllContacts
{
    //获取没有经过排序的联系人模型
    [PPGetAddressBook getOriginalAddressBook:^(NSArray<PPPersonModel *> *addressBookArray) {
        //addressBookArray:原始顺序的联系人模型数组
        [self.dataAddContactsArr removeAllObjects];
        for (HomeQueryModel *query in self.dataArr) {
            BOOL isHave = false;
            for (PPPersonModel *model in addressBookArray) {
                if ([model.name isEqualToString:[NSString stringWithFormat:@"A名录_%@",query.compname]]) {
                    isHave = true;
                }
            }
            if (!isHave) {
                [self.dataAddContactsArr addObject:query];
            }
        }
        if (self.dataAddContactsArr.count>0) {
            [self requestQueryCountData];
            
        }else
        {
            
        }
    } authorizationFailure:^{
        [self showAlertViewAboutNotAuthorAccessContact];
    }];
}

//添加新的联系人
-(void) addConacts{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
             _addHUD = [SWTProgressHUD showHUDAddedTo:self.view text:[NSString stringWithFormat:@"正在添加"]];
        });
       
        int i = 0;
        for (i = 0; i<[self.dataAddContactsArr count]; i++) {
            HomeQueryModel *m = self.dataAddContactsArr[i];
            [self addNewContact:m];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [label setText:[NSString stringWithFormat:@"正在添加:%@", phone]];
                [_addHUD setMessage:[NSString stringWithFormat:@"正在添加:%d/%lu", (i+1),self.dataAddContactsArr.count]];
//                NSLog(@"正在添加:%d-%@",i, m.compname);
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_addHUD) {
                [_addHUD hideAnimated:YES];
            }
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"所有联系人导入成功"];
        });
    });
}

//phoneList 为包含多对号码属性字典的数组，用于一个为一个联系人添加多个号码
- (void)addNewContact:(HomeQueryModel *)model
{
    //name
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    CFErrorRef error = NULL;
    ABRecordRef newPerson = ABPersonCreate();
    NSString *name = [NSString stringWithFormat:@"A名录_%@",model.compname];
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, @"", &error);
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    NSArray *array = [model.tel componentsSeparatedByString:@","];
    for (NSString *str in array) {
        NSArray *strArray = [str componentsSeparatedByString:@" "];
        for (NSString *tel in strArray) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(tel), (__bridge CFStringRef)(tel), NULL);
            ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, nil);
            NSLog(@"%@",tel);
        }
    }
    
    
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    
    CFRelease(multiPhone);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);
    
}


#pragma mark 删除一个号码
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
            
            ABAddressBookSave(addressBook, NULL);
            
//            ABAddressBookRef addressBook = ABAddressBookCreate();
//            CFArrayRef records;
//            // 获取通讯录中全部联系人
//            records = ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            // 遍历全部联系人，检查已存号码库信息数量
//            for (int i=0; i<addressBookArray.count; i++)
//            {
//
//                ABRecordRef record = (__bridge ABRecordRef)addressBookArray[i];
//                ABAddressBookRemoveRecord(addressBook, record , NULL);
            
//                CFErrorRef error = NULL;
//                ABRecordRef record = ABPersonCreate();
//                ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)(addressBookArray[i].name), &error);
//                ABRecordSetValue(record, kABPersonLastNameProperty, @"", &error);
//
//                CFTypeRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
//                NSString *firstLabel = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phones,0));
//                //这里是特殊情况的比较号码并删除，正常是比较姓名即可
//                if ([firstLabel containsString:@"_超级名录"])
//                {
//                    ABAddressBookRemoveRecord(addressBook, record, nil);
//                }
//                NSLog(@"已经删除%@",addressBookArray[i].name);
//            }
            
            ABAddressBookSave(addressBook, nil);
            CFRelease(addressBook);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_hud) {
                    [_hud hideAnimated:YES];
                }
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"删除成功成功"];
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
        if (SWTUtils.isSetting) {
            LoginVC *login = [[LoginVC alloc] init];
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:navigationController animated:YES completion:nil];
            return;
        }
        if(SWTUtils.isLoginV){
            //有通讯录权限-- 进行下一步操作
            [self getAllContacts];
        }else
        {
             [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
        }
        
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

#pragma  mark ------------添加通讯录  end------------

#pragma  mark ------------定位相关  start------------

- (void)getLocation{
    [self configLocationManager];
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
            if ([self.nProvincename isEqualToString:@"北京"]&&regeocode.province) {
                self.nProvincename = regeocode.province;
                self.nCityname = regeocode.city;
                [self.btnSelectAddress setTitle:[NSString stringWithFormat:@"%@-%@",self.nProvincename,self.nCityname] forState:UIControlStateNormal];
            }
            
        }
    }];
}
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //   定位超时时间，最低2s，此处设置为2s
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    //   逆地理请求超时时间，最低2s，此处设置为2s
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}
#pragma  mark ------------定位相关  end------------

@end

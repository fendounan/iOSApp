//
//  IntelligentRecommendationVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "IntelligentRecommendationVC.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "HomeQueryModel.h"
#import "HomePageCell.h"
#import "HomeSendMessageVC.h"
#import "PPGetAddressBook.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "SWTUtils.h"
#import "BaseNavigationController.h"
#import "LoginVC.h"
//高德地图时间设置
#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3
@interface IntelligentRecommendationVC ()<UITableViewDelegate,UITableViewDataSource,AMapLocationManagerDelegate>

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UILabel *labTiShi;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *dataAddContactsArr;

//普通的等待框
@property (nonatomic, strong) SWTProgressHUD *hud;
//添加通讯录时候的等待框  因为需要重新赋值内容 所以重新创建了一个
@property (nonatomic, strong) SWTProgressHUD *addHUD;

//定位
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

static NSString * HomePageCellID = @"HomePageCellID";

@implementation IntelligentRecommendationVC
{
    int p;
    NSString *pointx;
    NSString *pointy;
    NSString *strAddress;
    NSString *strProvince;
    NSString *strCity;
    BOOL _isNew;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    p = 0;
    pointx = @"";
    pointy = @"";
    strAddress = @"";
    strProvince = @"";
    strCity = @"";
    _isNew = true;
    self.navigationItem.title = @"智能推荐";
    
    [self.view addSubview:self.tableHeaderView];
    
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tableHeaderView.mas_bottom).offset(5);
    }];
    
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，也就是调用 self 的 loadNewData 方法）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        p = 0;
        _isNew = true;
        [self requestBtnQueryData:false];
    }];
    
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，即调用 self 的 loadMoreData 方法）
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self requestBtnQueryData:false];
    }];
    
    if ([SWTReachability shareInstance].isNetworkReachable) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍等"];
        [self getLocation];
    } else {
        [self showNoNetworkView];
    }
    
}

#pragma mark - lazy load

- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:HomePageCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}


-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        //添加发短信、拨打电话功能
        CGFloat vContactHeight = 50.0f;
        CGFloat padding = 10;
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, vContactHeight)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        UIView *vContactBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, vContactHeight)];
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
        
        _tableHeaderView.height = vContactHeight;
        
    }
    return _tableHeaderView;
}

#pragma mark 查询搜索结果

- (void)requestBtnQueryData:(BOOL)isShow{
    
    if (!_isNew) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"数据持续更新中，敬请期待"];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    if (isShow) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍等"];
    }
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"pointx"] = pointx;
    paramesDic[@"pointy"] = pointy;
    paramesDic[@"address"] = strAddress;
    paramesDic[@"province"] = strProvince;
    paramesDic[@"city"] = strCity;
    paramesDic[@"p"] = @(p);
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/QueryByPoint") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        NSArray *listArr = dic[@"data"][@"data"];
        self.labTiShi.text = dic[@"data"][@"message"];
        
        if ([dic[@"data"][@"lastpage"] intValue] == 1) {
            _isNew = false;
        }
        
        if (listArr.count) {
            p++;
            self.tableView.hidden = NO;
            [self.dataArr removeAllObjects];
            for (NSDictionary *tempDic in listArr) {
                HomeQueryModel *model = [[HomeQueryModel alloc] initWithDictionary:tempDic error:nil];
                [self.dataArr addObject:model];
            }
        }else
        {
            if (p == 0) {
                [self.dataArr removeAllObjects];
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
        if (p == 0) {
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
        if (p == 0) {
            [self showErrorDataView];
        } else {
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        }
    }];
}


- (void)requestQueryCountData
{
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍等"];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"count"] = @(self.dataAddContactsArr.count);
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/ExportToMobile") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        
        
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
            HomeSendMessageVC *homeSendMessageVC = [[HomeSendMessageVC alloc] init];
            [homeSendMessageVC setMessage:message];
            homeSendMessageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:homeSendMessageVC animated:YES];
        }
    }else
    {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
    }

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
            //            [self requestQueryCountData];
            [self addConacts];
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
                
                if (_addHUD) {
                    [_addHUD hideAnimated:NO];
                }
                [_addHUD setMessage:[NSString stringWithFormat:@"正在添加:%d/%lu", (i+1),self.dataAddContactsArr.count]];
                NSLog(@"正在添加:%d-%@",i, m.compname);
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_addHUD) {
                [_addHUD hideAnimated:YES];
            }
            //            [SWTProgressHUD toastMessageAddedTo:self.view message:@"所有联系人导入成功"];
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
        //有通讯录权限-- 进行下一步操作
        [self getAllContacts];
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

#pragma mark - private

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

- (void)networkReachability{
    [self dismissNoNetworkView];
    [self dismissErrorDataView];
    _isNew = true;
    [self requestBtnQueryData:true];
}

- (void)reRequestData{
    [self dismissNoNetworkView];
    [self dismissErrorDataView];
    _isNew = true;
    [self requestBtnQueryData:true];
}

#pragma  mark ------------定位相关  start------------

- (void)getLocation{
    [self configLocationManager];
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            [self requestBtnQueryData:false];
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
            return;
        }
        pointx = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
        pointy = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
        if (regeocode&&regeocode.province)
        {
            NSLog(@"reGeocode:%@", regeocode);
            strProvince = regeocode.province;
            strCity = regeocode.city;
            strAddress = regeocode.formattedAddress;
            
        }
        [self requestBtnQueryData:false];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

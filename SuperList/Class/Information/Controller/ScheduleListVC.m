//
//  ScheduleListVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/12.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ScheduleListVC.h"
#import "Masonry.h"
#import "MyTaskModel.h"
#import "SWTProgressHUD.h"
#import "MJRefresh.h"
#import "ScheduleListCell.h"
#import "CreateScheduleVC.h"
#import "UIBarButtonItem+ColorAndFont.h"

@interface ScheduleListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *submitBtn;

@property (nonatomic, strong) SWTProgressHUD *hud;

#pragma mark 右边按钮
@property (nonatomic, strong) UIBarButtonItem *rightItem;


@end

static NSString *ScheduleListCellID = @"ScheduleListCellID";

@implementation ScheduleListVC
{
    int p;
    CGFloat _btnH;
    BOOL _isShowDelete;
    BOOL _isFirstLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    _btnH = 50;
    p = 0;
    _isShowDelete = false;
    _isFirstLoad = true;
    self.navigationItem.title = @"我的日程";
    [self setUpView];
    self.tableView.hidden = YES;
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，也就是调用 self 的 loadNewData 方法）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        p = 0;
        [self requestData];
    }];
    
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，即调用 self 的 loadMoreData 方法）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    
    
    if ([SWTReachability shareInstance].isNetworkReachable) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        [self requestData];
    } else {
        [self showNoNetworkView];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if (!_isFirstLoad) {
        p = 0;
        [self requestData];
    }
    
}

- (void)setUpView{
    
    [self createRightBarButtonItem];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitBtn = submitBtn;
    submitBtn.frame = CGRectMake(0, Main_Screen_Height - _btnH - 64, Main_Screen_Width, _btnH);
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [submitBtn setTitle:@"创建日程" forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(_btnH);
    }];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(submitBtn.mas_top);
    }];
}
#pragma mark 创建右边按钮
- (void)createRightBarButtonItem{
    
    self.rightItem = [UIBarButtonItem barButtomItemWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(rightAction) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14]];
    
    self.navigationItem.rightBarButtonItem = self.rightItem;
}


#pragma mark 点击事件

- (void)rightAction{
    
    _isShowDelete = !_isShowDelete;
    
    if (_isShowDelete) {
        self.rightItem.title = @"完成";
        [self.submitBtn setTitle:@"删除" forState:UIControlStateNormal];
    }else
    {
        self.rightItem.title = @"删除";
        [self.submitBtn setTitle:@"创建日程" forState:UIControlStateNormal];
        for (MyTaskModel *model in self.dataArr) {
            model.isSelect = @"0";
        }
    }
    [self.tableView reloadData];
}
- (void)submitAction{
    if (_isShowDelete) {
        [self requestDelData];
    }else
    {
        CreateScheduleVC *createScheduleVC = [[CreateScheduleVC alloc] init];
        [self.navigationController pushViewController:createScheduleVC animated:YES];
    }
}


#pragma mark - request data

- (void)requestData{
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"p"] = @(p);
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Task/MyTask") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        _isFirstLoad = false;
        [self resetData:dic[@"data"]];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (p == 0) {
            [self showErrorDataView];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (p == 0) {
            [self showErrorDataView];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)resetData:(NSDictionary *)dict{
    
    if (p == 0) {
        [self.dataArr removeAllObjects];
    }
    if (dict.count>0) {
        p++;
        self.tableView.hidden = NO;
    }else
    {
        if (p == 0) {
            self.tableView.hidden = YES;
            [self showListEmptyView:self.tableView];
        }
    }
    for (NSDictionary *tempDic in dict) {
        MyTaskModel *model = [[MyTaskModel alloc] initWithDictionary:tempDic error:nil];
        model.isSelect = @"0";
        [self.dataArr addObject:model];
    }
    [self.tableView reloadData];
    
}

#pragma mark 删除日程

- (void)requestDelData{
    NSString *strID = @"";
    for (MyTaskModel *model in self.dataArr) {
        if ([model.isSelect intValue] == 1) {
            if ([strID isEqualToString:@""]) {
                strID = model.Id;
            }else
            {
                strID = [NSString stringWithFormat:@"%@,%@",strID,model.Id];
            }
        }
    }
    
    if ([strID isEqualToString:@""]) {
         [SWTProgressHUD toastMessageAddedTo:self.view message:@"请先选择要删除的日程"];
        return;
    }
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"id"] = strID;
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Task/Delete") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        
        
        int num = (int)self.dataArr.count-1;
        for (int i = num; i>=0; i--) {
            MyTaskModel *model = self.dataArr[i];
            if ([model.isSelect intValue] == 1) {
                [self.dataArr removeObject:model];
            }
        }
        
        
        [self.tableView reloadData];
        
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
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"操作失败请重试"];
    }];
}


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
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
    [self requestData];
}

- (void)reRequestData{
    [self dismissNoNetworkView];
    [self dismissErrorDataView];
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
    [self requestData];
}

#pragma mark - lazy load

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerNib:[UINib nibWithNibName:@"ScheduleListCell" bundle:nil] forCellReuseIdentifier:ScheduleListCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 90;
    }
    return _tableView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

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
    ScheduleListCell *cell = [tableView dequeueReusableCellWithIdentifier:ScheduleListCellID forIndexPath:indexPath];
    if (_isShowDelete) {
        cell.isDelete = true;
    }else
    {
        cell.isDelete = false;
    }
    cell.cellmodel = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark 回调监听
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyTaskModel *model = self.dataArr[indexPath.row];
    if (_isShowDelete) {
        if ([model.isSelect intValue] == 1) {
            model.isSelect = @"0";
        }else
        {
            model.isSelect = @"1";
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }else
    {
        CreateScheduleVC *createScheduleVC = [[CreateScheduleVC alloc] init];
        createScheduleVC.taskModel = model;
        [self.navigationController pushViewController:createScheduleVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

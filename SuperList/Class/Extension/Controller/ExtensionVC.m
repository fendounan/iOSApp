//
//  DiscoverVC.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "ExtensionVC.h"
#import "SWTUtils.h"
#import "Masonry.h"
#import "SWTProgressHUD.h"
#import "SWTReachability.h"
#import "ExtensionModel.h"
#import "ExtensionCell.h"
#import <MJRefresh/MJRefresh.h>
#import "ExtensionListVC.h"

@interface ExtensionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) SWTProgressHUD *hud;


@end

static NSString * ExtensionCellID = @"ExtensionCellID";

@implementation ExtensionVC{
    BOOL _isLoadedData; // 标识数据是否加载过  YES:加载过  NO：没有加载过
    int p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"推广";
    p = 0;
    
    [self setUpView];
    self.tableView.hidden = YES;
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，也就是调用 self 的 loadNewData 方法）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        p = 0;
        [self requestData];
    }];
    
//    // 设置回调（一旦进入刷新状态，就调用 target 的 action，即调用 self 的 loadMoreData 方法）
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestData)];


    if ([SWTReachability shareInstance].isNetworkReachable) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        p = 0;
        [self requestData];
    } else {
        [self showNoNetworkView];
    }
}

- (void)setUpView{
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view); 
    }];
}

#pragma mark - request data

- (void)requestData{
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"p"] = @(p);
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/BusinessShare/ShareCategory") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [self resetData:dic[@"data"]];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (!_isLoadedData) {
            [self showErrorDataView];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (!_isLoadedData) {
            [self showErrorDataView];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)resetData:(NSDictionary *)dict{
    _isLoadedData = YES;
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
            [self noDataView];
        }
    }
    for (NSDictionary *tempDic in dict) {
        ExtensionModel *model = [[ExtensionModel alloc] initWithDictionary:tempDic error:nil];
        [self.dataArr addObject:model];
    }
    [self.tableView reloadData];
    
    
    
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
    if (!_isLoadedData) {
        [self dismissNoNetworkView];
        [self dismissErrorDataView];
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        [self requestData];
    }
}

- (void)reRequestData{
    if (!_isLoadedData) {
        [self dismissNoNetworkView];
        [self dismissErrorDataView];
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        [self requestData];
    }
}

#pragma mark - lazy load

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerNib:[UINib nibWithNibName:@"ExtensionCell" bundle:nil] forCellReuseIdentifier:ExtensionCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        CGFloat rowHeight = ([UIScreen mainScreen].bounds.size.width - 20) * 5 / 12 + 10;
        _tableView.rowHeight = rowHeight;
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
    view.backgroundColor = [UIColor whiteColor];
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
    ExtensionCell *cell = [tableView dequeueReusableCellWithIdentifier:ExtensionCellID forIndexPath:indexPath];
    cell.model = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ExtensionModel *model = self.dataArr[indexPath.row];
    ExtensionListVC *listVC = [[ExtensionListVC alloc] init];
    listVC.categoryName = model.Name;
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

@end

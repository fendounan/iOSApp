//
//  InformationListVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "InformationListVC.h"
#import "SWTProgressHUD.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "SWTWebViewController.h"
#import "InformationListCell.h"
#import "InformationListModel.h"


@interface InformationListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) SWTProgressHUD *hud;

@end

static NSString * InformationListCellID = @"InformationListCellID";

@implementation InformationListVC
{
    int p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"推广";
    p = 0;
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
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
    paramesDic[@"category"] = self.category;
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Documents/Documents") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
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
        self.tableView.hidden = NO;
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
        InformationListModel *model = [[InformationListModel alloc] initWithDictionary:tempDic error:nil];
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
        [_tableView registerNib:[UINib nibWithNibName:@"InformationListCell" bundle:nil] forCellReuseIdentifier:InformationListCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        CGFloat rowHeight = 80;
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
    InformationListCell *cell = [tableView dequeueReusableCellWithIdentifier:InformationListCellID forIndexPath:indexPath];
    cell.cellmodel = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    InformationListModel *model = self.dataArr[indexPath.row];
    SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
    webViewVC.urlString = model.URL;
    webViewVC.titleString = model.title;
    webViewVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewVC animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

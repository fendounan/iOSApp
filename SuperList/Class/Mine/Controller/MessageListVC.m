//
//  MessageListVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "MessageListVC.h"

#import "SWTWebViewController.h"
#import "MessageListCell.h"
#import "SWTProgressHUD.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "MessageListModel.h"

@interface MessageListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) SWTProgressHUD *hud;

@end
static NSString *MessageListCellID = @"MessageListCellID";
@implementation MessageListVC
{
    int p;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"短信记录";
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
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Sms/List") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
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
    [self hideListEmptyView];
    [self dismissErrorDataView];
    [self dismissNoNetworkView];
    self.tableView.hidden = NO;
    if (p == 0) {
        [self.dataArr removeAllObjects];
    }
    if (dict.count>0) {
        p++;
        
    }else
    {
        if (p == 0) {
            
            [self showListEmptyView:self.tableView];
        }
    }
    for (NSDictionary *tempDic in dict) {
        MessageListModel *model = [[MessageListModel alloc] initWithDictionary:tempDic error:nil];
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
        [_tableView registerNib:[UINib nibWithNibName:@"MessageListCell" bundle:nil] forCellReuseIdentifier:MessageListCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

// 先给cell表格一个预估计高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
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
    MessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageListCellID forIndexPath:indexPath];
    cell.cellmodel = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

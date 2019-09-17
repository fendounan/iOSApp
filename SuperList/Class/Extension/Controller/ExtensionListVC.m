//
//  ExtensionListVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/9.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ExtensionListVC.h"
#import "Masonry.h"
#import "ExtensionListModel.h"
#import "ExtensionListCollectionViewCell.h"
#import "MJRefresh.h"
#import "SWTWebViewController.h"

@interface ExtensionListVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)NSMutableArray  *listArr;
/** 表格列表 */
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SWTProgressHUD *hud;


@end

static NSString * const ExtensionListCollectionViewCellID = @"ExtensionListCollectionViewCellID";

@implementation ExtensionListVC
{
    int p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.categoryName;
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    p = 0;
    [self.view addSubview:self.collectionView];
    self.collectionView.hidden = YES;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，也就是调用 self 的 loadNewData 方法）
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        p = 0;
        [self requestData];
    }];
    
    //    // 设置回调（一旦进入刷新状态，就调用 target 的 action，即调用 self 的 loadMoreData 方法）
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    
    
    if ([SWTReachability shareInstance].isNetworkReachable) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        p = 0;
        [self requestData];
    } else {
        [self noNetworkView];
    }
}

#pragma mark - request data

- (void)requestData{
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"p"] = @(p);
    paramesDic[@"categoryname"] = self.categoryName;
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/BusinessShare/List") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        NSArray *listArr = dic[@"data"];
        if (p == 0) {
             [self.listArr removeAllObjects];
        }
        if (listArr.count) {
            [self hideListEmptyView];
            [self dismissErrorDataView];
            [self dismissNoNetworkView];
            [self hideListEmptyView];
            self.collectionView.hidden = NO;
            p++;
            for (NSDictionary *tempDic in listArr) {
                ExtensionListModel *model = [[ExtensionListModel alloc] initWithDictionary:tempDic error:nil];
                [self.listArr addObject:model];
            }
        } else {
            if (p == 0) {
                [self showListEmptyViewCollection:self.collectionView];
            }
        }
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (p == 0) {
            [self reRequestData];
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (p == 0) {
            [self reRequestData];
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

-(UICollectionView *)collectionView{
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //水平间距 最后会以item宽高为准
        layout.minimumInteritemSpacing = 10;
        //垂直距离
        layout.minimumLineSpacing = 5;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,0) collectionViewLayout:layout];
        [_collectionView registerNib:[UINib nibWithNibName:@"ExtensionListCollectionViewCell"
                                                           bundle: nil] forCellWithReuseIdentifier:ExtensionListCollectionViewCellID];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor hexStringToColor:@"#fafafa"];
        _collectionView.bounces = YES;
        
    }
    return _collectionView;
}

-(NSMutableArray *)listArr
{
    if (_listArr == nil) {
        _listArr = [NSMutableArray array];
        
    }
    return _listArr;
}

#pragma -mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.listArr.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ExtensionListModel *model = self.listArr[indexPath.row];
    
    ExtensionListCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:ExtensionListCollectionViewCellID forIndexPath:indexPath];
    
    if (collectionViewCell == nil) {
        
        collectionViewCell = [[ExtensionListCollectionViewCell alloc]init];
    }
    collectionViewCell.cellmodel = model;
    
    return collectionViewCell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(Main_Screen_Width/2-8, (Main_Screen_Width/2.f-10)*(140/100.f));
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //上左下右
    return UIEdgeInsetsMake(5,5, 0, 5);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExtensionListModel *model = self.listArr[indexPath.row];
    if ([model.IsNavigate intValue] == 1) {
        SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
        webViewVC.urlString = model.Url;
        webViewVC.titleString = model.title;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

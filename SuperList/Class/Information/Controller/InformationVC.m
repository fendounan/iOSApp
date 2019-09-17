//
//  InformationVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/10.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "InformationVC.h"
#import "Masonry.h"
#import "SWTWebViewController.h"
#import "HomePageVC.h"
#import "MJRefresh.h"
#import "InformationModel.h"
#import "InformationCategorysModel.h"
#import "InformationVFlowLayout.h"
#import "InformationCell.h"
#import "SWTWebViewController.h"
#import "InformationListVC.h"
#import "HelpCenterVC.h"
#import "IntelligentRecommendationVC.h"
#import "WantToPromoteVC.h"
#import "ScheduleListVC.h"
#import "SWTUtils.h"
#import "LoginVC.h"
#import "BaseNavigationController.h"

@interface InformationVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIView *viewHeaderView;
@property (nonatomic, strong) NSMutableArray  *listArr;
@property (nonatomic, strong) UIView *bottomView;
/** 表格列表 */
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SWTProgressHUD *hud;
@end

static NSString *ItemIdentifier = @"ItemIdentifier";

static NSString *leaveDetailsHeadID = @"leaveDetailsHeadID";

static NSString *leaveDetailsFooterID = @"leaveDetailsFooterID";

@implementation InformationVC{
    int p;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestAppleVerifyData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"信息";
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    p = 0;
    [self.view addSubview:self.viewHeaderView];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.viewHeaderView.mas_bottom).offset(6);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.viewHeaderView.mas_bottom).offset(6);
    }];
    self.bottomView.hidden = YES;
    
    // 设置回调（一旦进入刷新状态，就调用 target 的 action，也就是调用 self 的 loadNewData 方法）
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        p = 0;
        [self requestData];
    }];
    
    if ([SWTReachability shareInstance].isNetworkReachable) {
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        [self requestData];
    } else {
        [self showNoNetworkView];
    }
}

-(NSMutableArray *)listArr
{
    if (_listArr == nil) {
        _listArr = [NSMutableArray array];
        
    }
    return _listArr;
}

#pragma mark 顶部九宫格布局  因为不让随着列表滚动所以单独拿出来
- (UIView *)viewHeaderView
{
    if (!_viewHeaderView) {
        CGFloat padding = 20;
        
        _viewHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _viewHeaderView.backgroundColor = [UIColor whiteColor];
        
        CGFloat vSpacing = 20.0f;
        CGFloat itemWidth = (kScreenWidth)/3;
        CGFloat itemHeight = 60.0f;

        
        NSArray *imageArr = @[@"icon_1",@"icon_2",@"icon_6",@"icon_4",@"icon_5",@"icon_7"];
        NSArray *titleArr = @[@"企业名录",@"智能推荐",@"我要推广",@"日程",@"帮助中心",@"定制服务"];
        int num = (int)imageArr.count;
        
        
        //每排数量
        int moduleNumber = 3;
        //总共多少排
        int vNumber = ceilf(num/moduleNumber);
        
        
        for (int i = 0; i < num; i++) {
            CGRect frame = CGRectMake(i%moduleNumber*itemWidth,
                                      i/moduleNumber*(itemHeight+vSpacing)+padding,
                                      itemWidth,itemHeight);
            
            UIView *toolView = [self toolViewWithFrame:frame imageName:imageArr[i] title:titleArr[i]];
            toolView.tag = 1000+i;
            [_viewHeaderView addSubview:toolView];
            
            [toolView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickAction:)]];
        }
        
        _viewHeaderView.height = 2*padding + vNumber*itemHeight+(vNumber-1)*vSpacing;
    }
    return _viewHeaderView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

#pragma mark - private 顶部九宫格工具类

- (UIView *)toolViewWithFrame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title{
    UIView *toolView = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [toolView addSubview:imageView];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = title;
    titleLab.textColor = [UIColor hexStringToColor:@"#999999"];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:13];
    [toolView addSubview:titleLab];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(toolView.mas_centerX);
        make.top.equalTo(toolView.mas_top);
        make.width.height.mas_equalTo(50);
    }];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(toolView);
    }];
    
    return toolView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        InformationVFlowLayout *informationvfl=[[InformationVFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0) collectionViewLayout:informationvfl];
        //一定要注册cell，注册的是原生的
        //[myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ItemIdentifier];
        //一定要注册cell，注册的是自定义的
        [_collectionView registerNib:[UINib nibWithNibName:@"InformationCell"
                                                    bundle: nil] forCellWithReuseIdentifier:ItemIdentifier];
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.showsVerticalScrollIndicator=NO;
        _collectionView.backgroundColor=[UIColor hexStringToColor:@"#ffffff"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //一定要注册headview
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:leaveDetailsHeadID];
        //一定要注册footerview
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:leaveDetailsFooterID];
    }
    
    return _collectionView;
}


#pragma mark - request data

- (void)requestData{
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"p"] = @(p);
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Documents/Categorys") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        NSArray *listArr = dic[@"data"];
        if (p == 0) {
            [self.listArr removeAllObjects];
        }
        if (listArr.count) {
            [self dismissErrorDataView];
            [self dismissNoNetworkView];
            self.bottomView.hidden = YES;
            self.collectionView.hidden = NO;
            for (NSDictionary *tempDic in listArr) {
                InformationModel *model = [[InformationModel alloc] initWithDictionary:tempDic error:nil];
                [self.listArr addObject:model];
            }
        } else {
            if (p == 0) {
                 [self showErrorDataView];
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
            [self showErrorDataView];
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        if (p == 0) {
            [self showErrorDataView];
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
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


#pragma  mark 顶部九宫格点击事件
- (void)ClickAction:(UITapGestureRecognizer *)tapGesture{
    UIView *view = tapGesture.view;
    NSInteger tag = view.tag;
    if (tag == 1000) { // 企业名录
        
        [self.tabBarController setSelectedIndex:0];
        
    } else if (tag == 1001) { // 智能推广
        
        IntelligentRecommendationVC *intelligentRecommendationVC = [[IntelligentRecommendationVC alloc] init];
        intelligentRecommendationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:intelligentRecommendationVC animated:YES];
    } else if (tag == 1002) { // 我要推广
        if (SWTUtils.isSetting) {
            LoginVC *login = [[LoginVC alloc] init];
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:navigationController animated:YES completion:nil];
            return;
        }
        if (SWTUtils.isLogin) {
            if(SWTUtils.isLoginV){
                WantToPromoteVC *wantToPromoteVC = [[WantToPromoteVC alloc] init];
                wantToPromoteVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wantToPromoteVC animated:YES];
            }else
            {
                [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
            }
        }else{
            LoginVC *login = [[LoginVC alloc] init];
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
        
        
        
    } else if (tag == 1003) { // 日程
        
        if (SWTUtils.isLogin) {
            ScheduleListVC *scheduleListVC = [[ScheduleListVC alloc] init];
            scheduleListVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:scheduleListVC animated:YES];
        }else{
            LoginVC *login = [[LoginVC alloc] init];
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
    } else if (tag == 1004) { // 帮助中心
        
        HelpCenterVC *helpCenterVC = [[HelpCenterVC alloc] init];
        helpCenterVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:helpCenterVC animated:YES];
    } else if (tag == 1005) { // 定制服务
        
        SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
        webViewVC.urlString = [NSString stringWithFormat:@"%@page/CusService",kHost];
        webViewVC.titleString = @"定制服务";
        webViewVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewVC animated:YES];
        
    }
}


//有多少个sections
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return self.listArr.count;
    
}
//每个section 中有多少个items
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    InformationModel *model = self.listArr[section];
    return model.Categorys.count;
    
}
//section X item X位置处应该显示什么内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //自定义cell
    InformationModel *model = self.listArr[indexPath.section];
    
    InformationCategorysModel *cateModel = [[InformationCategorysModel alloc] initWithDictionary:model.Categorys[indexPath.row] error:nil];
    
    InformationCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:ItemIdentifier forIndexPath:indexPath];
    
    collectionViewCell.cellmodel = cateModel;
    
    return collectionViewCell;
}
//cell的header与footer的显示内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *reusableHeaderView = nil;
        
        if (reusableHeaderView==nil) {
            
            reusableHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:leaveDetailsHeadID forIndexPath:indexPath];
            reusableHeaderView.backgroundColor = [UIColor whiteColor];
            
            //这部分一定要这样写 ，否则会重影，不然就自定义headview
            UILabel *label = (UILabel *)[reusableHeaderView viewWithTag:100];
            
            UILabel *labelLine = (UILabel *)[reusableHeaderView viewWithTag:101];
            
            if (!label) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 50)];
                label.tag = 100;
                label.textColor = [UIColor hexStringToColor:@"#999999"];
                label.font = FONT(13);
                [reusableHeaderView addSubview:label];
                
                
                labelLine = [[UILabel alloc] init];
                labelLine.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
                [reusableHeaderView addSubview:labelLine];
                [labelLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.equalTo(reusableHeaderView);
                    make.height.equalTo(@0.5);
                }];
            }
            InformationModel *model = self.listArr[indexPath.section];
            label.text = model.Intro;
            
            
        }
        
        return reusableHeaderView;
        
    }else if (kind == UICollectionElementKindSectionFooter){
        
        UICollectionReusableView *reusableFooterView = nil;
        
        if (reusableFooterView == nil) {
            
            reusableFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter  withReuseIdentifier:leaveDetailsFooterID forIndexPath:indexPath];
            reusableFooterView.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
            reusableFooterView.height = 5;
        }
        
        return reusableFooterView;
    }
    return nil;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //上左下右
    return UIEdgeInsetsMake(1,0, 1, 0);
}
//点击cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (SWTUtils.isSetting) {
        LoginVC *login = [[LoginVC alloc] init];
        BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:login];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    }
    if(SWTUtils.isLoginV){
        InformationModel *model = self.listArr[indexPath.section];
        
        InformationCategorysModel *cateModel = [[InformationCategorysModel alloc] initWithDictionary:model.Categorys[indexPath.row] error:nil];
        
        if ([cateModel.ListContainer isEqualToString:@"WebPage"]) {
            SWTWebViewController *webViewVC = [[SWTWebViewController alloc] init];
            webViewVC.urlString = cateModel.Url;
            webViewVC.titleString = cateModel.CategoryName;
            webViewVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewVC animated:YES];
        }else
        {
            InformationListVC *listVC = [[InformationListVC alloc] init];
            listVC.category = cateModel.CategoryName;
            listVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:listVC animated:YES];
        }
    }else
    {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"您暂无权限访问，请联系客服"];
    }
    
}



#pragma mark - private

- (void)showNoNetworkView{
    self.bottomView.hidden = NO;
    self.collectionView.hidden = YES;
    [self.bottomView addSubview:self.noNetworkView];
    
    [self.noNetworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
    }];
}

- (void)showErrorDataView{
    self.bottomView.hidden = NO;
    self.collectionView.hidden = YES;
    [self.bottomView addSubview:self.errorDataView];
    
    [self.errorDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.bottomView);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

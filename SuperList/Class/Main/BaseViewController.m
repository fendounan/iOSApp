//
//  BaseViewController.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "BaseViewController.h"
#import "SWTUtils.h"
#import <UMAnalytics/MobClick.h>
#import "Masonry.h"

@interface BaseViewController ()
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoadedData = NO;
    self.view.backgroundColor = [UIColor hexStringToColor:@"#ffffff"];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"navigation_back_white"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    _backButton = backButton;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    } else {
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -15;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
        self.navigationItem.leftBarButtonItems = @[spaceItem,backItem];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkNotReachability) name:@"SWTNetworkNotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachability) name:@"SWTNetworkReachable" object:nil];
}

- (void)viewDidLayoutSubviews{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        UINavigationItem *item = self.navigationItem;
        NSArray *array = item.leftBarButtonItems;
        if (array && array.count) {
            // 注意：这里设置的第一个leftBarButtonItem的customeView不能为空，也就是不要设置UIBarButtonSystemItemFixedSpace这种风格的item
            UIBarButtonItem *btnItem = array[0];
            UIView *view = [[btnItem.customView.superview superview] superview];
            NSArray *arrayConstraint = view.constraints;
            for (NSLayoutConstraint *constant in arrayConstraint) {
                CGFloat space = fabs(constant.constant);
                // 非plus手机为16 plus手机为20 
                if (space == 16 || space == 20) {
                    constant.constant = 0;
                }
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:NSStringFromClass(self.class)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:NSStringFromClass(self.class)];
}

- (void)setBackImage:(UIImage *)backImage{
    _backImage = backImage;
    
    [self.backButton setImage:backImage forState:UIControlStateNormal];
}
//影响到顶部标题栏的字体颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)networkReachability{
    
}

- (void)networkNotReachability{
    
}

- (void)reRequestData{
    
}

- (void)dismissErrorDataView{
    if (_errorDataView) {
        [_errorDataView removeFromSuperview];
        _errorDataView = nil;
    }
}

- (void)dismissNoNetworkView{
    if (_noNetworkView) {
        [_noNetworkView removeFromSuperview];
        _noNetworkView = nil;
    }
}

#pragma mark - action

- (void)backAction:(UIButton *)sender{
    [self back];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - lazy load

- (UIImageView *)navBarHairlineImageView{
    if (!_navBarHairlineImageView) {
        _navBarHairlineImageView = [SWTUtils findHairlineImageViewUnder:self.navigationController.navigationBar];
    }
    return _navBarHairlineImageView;
}

- (UIView *)noNetworkView{
    if (!_noNetworkView) {
        _noNetworkView = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"noNetwork"];
        [_noNetworkView addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"网络连接失败";
        lab.font = [UIFont systemFontOfSize:15];
        lab.textColor = [UIColor hexStringToColor:@"#999999"];
        [_noNetworkView addSubview:lab];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_noNetworkView);
            make.centerY.equalTo(_noNetworkView.mas_centerY);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noNetworkView.mas_centerX);
            make.bottom.equalTo(lab.mas_top).offset(0);
            make.width.mas_equalTo(140);
            make.height.mas_equalTo(140);
        }];
    }
    return _noNetworkView;
}

- (UIView *)errorDataView{
    if (!_errorDataView) {
        _errorDataView = [[UIView alloc] init];
        _errorDataView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"dataError"];
        [_errorDataView addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor hexStringToColor:@"#999999"];
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"获取数据错误请重试";
        [_errorDataView addSubview:lab];
        
        CGFloat buttonW = 150;
        CGFloat buttonH = 40;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"重新加载" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        [_errorDataView addSubview:button];
        button.layer.cornerRadius = buttonH / 2;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(reRequestData) forControlEvents:UIControlEventTouchUpInside];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_errorDataView);
            make.width.mas_equalTo(buttonW);
            make.height.mas_equalTo(buttonH);
        }];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_errorDataView);
            make.bottom.equalTo(button.mas_top).offset(-20);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_errorDataView.mas_centerX);
            make.bottom.equalTo(lab.mas_top).offset(-15);
            make.width.height.mas_equalTo(140);
        }];
        
    }
    return _errorDataView;
}

- (UIView *)listEmptyView{
    if (!_listEmptyView) {
        _listEmptyView = [[UIView alloc] init];
        _listEmptyView.backgroundColor = [UIColor clearColor];
        
        UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listEmpty"]];
        [_listEmptyView addSubview:emptyImageView];
        
        UILabel *textLab = [[UILabel alloc] init];
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.font = [UIFont systemFontOfSize:15];
        textLab.text = @"空空如也";
        textLab.textColor = [UIColor hexStringToColor:@"#cccccc"];
        [_listEmptyView addSubview:textLab];
        
        [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_listEmptyView.mas_centerY);
            make.left.right.equalTo(_listEmptyView);
        }];
        
        [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(textLab.mas_top).offset(0);
            make.centerX.equalTo(_listEmptyView.mas_centerX);
            make.width.height.mas_equalTo(90);
        }];
    }
    return _listEmptyView;
}

- (void)showListEmptyView:(UITableView *)tableView{
    if (!tableView) {
        return;
    } else {
        [tableView addSubview:self.listEmptyView];
        self.listEmptyView.frame = tableView.bounds;
    }
}


-(void)showListEmptyViewCollection:(UICollectionView *)collectionView
{
    if (!collectionView) {
        return;
    } else {
        [collectionView addSubview:self.listEmptyView];
        self.listEmptyView.frame = collectionView.bounds;
    }
}

- (void)hideListEmptyView{
    if (_listEmptyView) {
        [_listEmptyView removeFromSuperview];
        _listEmptyView = nil;
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWTNetworkNotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWTNetworkReachable" object:nil];
}



@end

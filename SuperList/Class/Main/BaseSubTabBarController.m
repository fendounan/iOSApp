//
//  BaseSubTabBarController.m
//  SuperList
//
//  Created by SWT on 2017/11/9.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "BaseSubTabBarController.h"
#import "SWTUtils.h"
#import <UMAnalytics/MobClick.h>
#import "Masonry.h"

@interface BaseSubTabBarController ()

@end

@implementation BaseSubTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoadedData = NO;
    self.view.backgroundColor = [UIColor hexStringToColor:@"#f1f2f6"];
    
    // 设置title的样式
    NSMutableDictionary *titleDic = [NSMutableDictionary dictionary];
    titleDic[NSForegroundColorAttributeName] = [UIColor hexStringToColor:@"#ffffff"];
    titleDic[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    self.navigationController.navigationBar.titleTextAttributes = titleDic;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkNotReachability) name:@"SWTNetworkNotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachability) name:@"SWTNetworkReachable" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:NSStringFromClass(self.class)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:NSStringFromClass(self.class)];
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
        _errorDataView.backgroundColor = self.view.backgroundColor;
        
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
            make.centerX.equalTo(_errorDataView);
            make.centerY.equalTo(_errorDataView).offset(buttonH);
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


- (UIView *)noDataView{
    if (!_errorDataView) {
        _errorDataView = [[UIView alloc] init];
        _errorDataView.backgroundColor = self.view.backgroundColor;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"dataError"];
        [_errorDataView addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor hexStringToColor:@"#999999"];
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"暂无数据";
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
        button.hidden = YES;
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWTNetworkNotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWTNetworkReachable" object:nil];
}



@end

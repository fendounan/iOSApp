//
//  ParameterSettingVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ParameterSettingVC.h"

#import "Masonry.h"
#import "SWTProgressHUD.h"
#import "UserEnertyModel.h"
#import "UIEdgeInsetsUILabel.h"

@interface ParameterSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) SWTProgressHUD *hud;
@property (nonatomic, strong) UserEnertyModel *userModel;
@property (nonatomic, strong) UISwitch *switchInformationSources;
@property (nonatomic, strong) UISwitch *switchGuolv;


@end


@implementation ParameterSettingVC
{
    CGFloat _btnH;
    NSString *_selectPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"参数设置";
    _btnH = 60;
    _selectPage = @"10";
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"] != nil) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];;
        self.userModel = [[UserEnertyModel alloc]initWithDictionary:dic error:nil];
    }
    [self setUpView];
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}
- (void) setUpView{
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, Main_Screen_Height - _btnH - 64, Main_Screen_Width, _btnH);
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [submitBtn setTitle:@"保存" forState:UIControlStateNormal];
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

#pragma mark - lazy load

//列表顶部视图
- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:@"HomePageCellID"];
        _tableView.tableFooterView = self.tableFooterView;
    }
    return _tableView;
}

//列表底部视图
- (UIView *)tableFooterView
{
    if (!_tableFooterView) {
        CGFloat footerHeight = 44;
        CGFloat vPadding = 15;
        CGFloat cellHeight = 44;
        _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        NSDictionary *dict = @{NSFontAttributeName : FONT(13)};
        NSString *contentStr=@"温馨提示：长按一行可以把号码复制到剪切板";
        CGSize size=[contentStr boundingRectWithSize:CGSizeMake(kScreenWidth-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        UILabel *labTiShi=[[UILabel alloc]init];
        
        if (size.height>44) {
            footerHeight = size.height+10;
        }
        
        labTiShi.font=FONT(13);
        labTiShi.numberOfLines = 0;
        labTiShi.text =contentStr;
        labTiShi.textColor = [UIColor hexStringToColor:@"#333333"];
        labTiShi.frame = CGRectMake(10, 0, kScreenWidth-20, footerHeight);
        
        
        //添加提示
        UIView *vTiShi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, footerHeight)];
        vTiShi.backgroundColor = [UIColor whiteColor];
        [vTiShi addSubview:labTiShi];
        [_tableFooterView addSubview:vTiShi];
        
        UIEdgeInsetsUILabel *labPageTitle = [[UIEdgeInsetsUILabel alloc] initWithFrame:CGRectMake(0, footerHeight+vPadding, kScreenWidth, cellHeight)];
        labPageTitle.backgroundColor = [UIColor whiteColor];
        labPageTitle.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        labPageTitle.text = @"每页条数设置";
        labPageTitle.textColor = [UIColor hexStringToColor:@"#333333"];
        labPageTitle.font = FONT(14);
         [_tableFooterView addSubview:labPageTitle];
        
        
        footerHeight = footerHeight+vPadding+cellHeight;
        
        //添加每页数据
        CGFloat padding = 10;//左右边距
        CGFloat vSpacing = 10.0f;//每个item距离
        CGFloat hSpacing = 20.0f;//每行item距离
        CGFloat itemWidth = (kScreenWidth-2*padding-3*hSpacing)/4;//每个item宽度
        CGFloat itemHeight = 30.0f;//每个item高度
        
        if ([self.userModel.Rows isEqualToString:@""]||[self.userModel.Rows isEqualToString:@"0"]) {
            self.userModel.Rows = _selectPage;
        }
        
        for (int i=0; i<[self pageArr].count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            btn.frame = CGRectMake(padding+i%4*(itemWidth+hSpacing),footerHeight+ i/4*(itemHeight+vSpacing)+padding, itemWidth, itemHeight);
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitle:[self pageArr][i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor hexStringToColor:@"#666666"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(fillContent:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = FONT(13);
            btn.layer.cornerRadius = 4.0;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor hexStringToColor:@"#e1e2e1"].CGColor;
            [_tableFooterView addSubview:btn];
            if ([self.userModel.Rows isEqualToString:[self pageArr][i]]) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor hexStringToColor:@"#e1e2e1"];
                _selectPage = [self pageArr][i];
            }
        }
        
        if ([self pageArr].count/4 == 0) {
            footerHeight = footerHeight +padding +([self pageArr].count/4+1)*(itemHeight+vSpacing);
        }else if ([self pageArr].count%4 == 0) {
            footerHeight = footerHeight +padding +([self pageArr].count/4)*(itemHeight+vSpacing);
        }else  {
            footerHeight = footerHeight +padding +([self pageArr].count/4+1)*(itemHeight+vSpacing);
        }
        
        
        
        // 是否显示信息来源
        UIView *bgInformationSources = [[UIView alloc] initWithFrame:CGRectMake(0, footerHeight, kScreenWidth, cellHeight)];
        bgInformationSources.backgroundColor = [UIColor whiteColor];
        bgInformationSources.userInteractionEnabled = YES;
        [_tableFooterView addSubview:bgInformationSources];
        
        UILabel *labInformationSources = [[UILabel alloc] init];
        labInformationSources.text = @"是否显示信息来源";
        labInformationSources.font = FONT(14);
        labInformationSources.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgInformationSources addSubview:labInformationSources];
        
        [labInformationSources mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(bgInformationSources).offset(padding);
            make.centerY.equalTo(bgInformationSources);
        }];
        
        UISwitch *switchInformationSources = [[UISwitch alloc] init];
        
        self.switchInformationSources = switchInformationSources;
        
        if ([self.userModel.ShowOrigin intValue] == 1) {
            switchInformationSources.on = YES;//设置初始为ON的一边
        }else
        {
            switchInformationSources.on = NO;//设置初始为ON的一边
        }
        
        [bgInformationSources addSubview:switchInformationSources];
        
        [switchInformationSources mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgInformationSources).offset(-padding);
            make.centerY.equalTo(bgInformationSources);
        }];
        
        footerHeight = footerHeight+cellHeight + vPadding;
        
        
        // 是否显示信息来源
        UIView *bgGuolv = [[UIView alloc] initWithFrame:CGRectMake(0, footerHeight, kScreenWidth, cellHeight)];
        bgGuolv.backgroundColor = [UIColor whiteColor];
        bgGuolv.userInteractionEnabled = YES;
        [_tableFooterView addSubview:bgGuolv];
        
        UILabel *labGuolv = [[UILabel alloc] init];
        labGuolv.text = @"是否过滤座机";
        labGuolv.font = FONT(14);
        labGuolv.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgGuolv addSubview:labGuolv];
        
        [labGuolv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(bgGuolv).offset(padding);
            make.centerY.equalTo(bgGuolv);
        }];
        
        UISwitch *switchGuolv = [[UISwitch alloc] init];
        
        self.switchGuolv = switchGuolv;
        
        if ([self.userModel.ShowTele intValue] == 1) {
            switchGuolv.on = YES;//设置初始为ON的一边
        }else
        {
            switchGuolv.on = NO;//设置初始为ON的一边
        }
        
        [bgGuolv addSubview:switchGuolv];
        
        [switchGuolv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgGuolv).offset(-padding);
            make.centerY.equalTo(bgGuolv);
        }];
        
        footerHeight = footerHeight+cellHeight;
        
        _tableFooterView.height = footerHeight;
        
        
    }
    return _tableFooterView;
}

#pragma mark 改变短信内容

- (void)fillContent:(UIButton *)btn
{
    int bTag = (int)[btn tag];
    for (int i = 0; i< [self pageArr].count; i++) {
        UIButton *myButton = (UIButton *)[self.view viewWithTag:(100+i)];
        if (bTag == (100+i)) {
            myButton.selected = YES;
            myButton.backgroundColor = [UIColor hexStringToColor:@"#e1e2e1"];
             _selectPage = [self pageArr][i];
        }else
        {
            myButton.selected = NO;
            myButton.backgroundColor = [UIColor whiteColor];
        }
    }
}

-(NSArray *)sourceArr{
    NSString *localVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    if (self.userModel) {
        return @[@{@"subtitle":localVersion,@"title":@"版本号"},
                 @{@"subtitle":self.userModel.DevId,@"title":@"特征码"},
                 @{@"subtitle":self.userModel.ActiveCode,@"title":@"推广码"}];
    }else
        return @[@{@"subtitle":@"",@"title":@"版本号"},
                 @{@"subtitle":@"",@"title":@"特征码"},
                 @{@"subtitle":@"",@"title":@"推广码"}];
}

-(NSArray *)pageArr{
    
    return @[@"10",@"20",@"50",@"80"];
        
}

#pragma mark UITableViewDataSource && UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        
        UILabel *flagLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        flagLabel.text = @"";
        flagLabel.font = [UIFont systemFontOfSize:15];
        flagLabel.textColor = [UIColor hexStringToColor:@"#333333"];
        [cell.contentView addSubview:flagLabel];
        flagLabel.tag = 10001;
        [flagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.right.equalTo(cell.contentView.mas_right).offset = -10;
        }];
        
        UILabel *line = [[UILabel alloc] init];
        line.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [cell.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(cell.contentView);
            make.height.equalTo(@0.5);
        }];
    }
    UILabel *label = [cell.contentView viewWithTag:10001];
    label.text = [self sourceArr][indexPath.row][@"subtitle"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor hexStringToColor:@"#333333"];
    cell.textLabel.text = [self sourceArr][indexPath.row][@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.userModel) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self sourceArr][indexPath.row][@"subtitle"];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"已复制到剪贴板"];
    }
}

#pragma mark 网络请求

- (void)submitAction{
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍后.."];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"rows"] = _selectPage;
    if ([self.switchInformationSources isOn]) {
        paramesDic[@"showorigin"] = @1;
    }else
    {
        paramesDic[@"showorigin"] = @0;
    }
    
    if ([self.switchGuolv isOn]) {
        paramesDic[@"showotele"] = @1;
    }else
    {
        paramesDic[@"showotele"] = @0;
    }
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Setting") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        [self.navigationController popViewControllerAnimated:YES];
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
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



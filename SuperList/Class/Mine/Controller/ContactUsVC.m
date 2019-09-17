//
//  ContactUsVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ContactUsVC.h"
#import "Masonry.h"
#import "ContactUsModel.h"
#import "SWTProgressHUD.h"

@interface ContactUsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) ContactUsModel *model;
@property (nonatomic, strong) SWTProgressHUD *hud;

@end


@implementation ContactUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"联系我们";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self request];
}

#pragma mark - lazy load

//列表顶部视图
- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:@"HomePageCellID"];
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = self.tableFooterView;
    }
    return _tableView;
}
-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        CGFloat headerHeight = kScreenWidth*382/750;
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, headerHeight)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initiatingprojects_home_company"]];
        [_tableHeaderView addSubview:topImageView];
        [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_tableHeaderView);
        }];
        
    }
    return _tableHeaderView;
}


//列表底部视图
- (UIView *)tableFooterView
{
    if (!_tableFooterView) {
        CGFloat footerHeight = 44;
        _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _tableFooterView.backgroundColor = [UIColor hexStringToColor:@"#e6e6e6"];
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
        [_tableFooterView addSubview:labTiShi];
        _tableFooterView.height = footerHeight;
    }
    return _tableFooterView;
}

-(NSArray *)sourceArr{
    
    if (self.model) {
        return @[@{@"subtitle":self.model.Wx,@"title":@"微信"},
                 @{@"subtitle":self.model.QQ,@"title":@"QQ"},
                 @{@"subtitle":self.model.Mobile,@"title":@"电话"}];
    }else
    return @[@{@"subtitle":@"",@"title":@"微信"},
             @{@"subtitle":@"",@"title":@"QQ"},
             @{@"subtitle":@"",@"title":@"电话"}];
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
    if (self.model) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self sourceArr][indexPath.row][@"subtitle"];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"已复制到剪贴板"];
    }
}

#pragma mark 网络请求

- (void)request{
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍后.."];
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Contact") parameters:nil usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
            _hud = nil;
        }
        self.model = [[ContactUsModel alloc] initWithDictionary:dic[@"data"] error:nil];
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
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


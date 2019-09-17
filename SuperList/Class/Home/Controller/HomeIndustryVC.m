//
//  HomeIndustryVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/3.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "HomeIndustryVC.h"
#import "Masonry.h"

@interface HomeIndustryVC ()<UITableViewDelegate,UITableViewDataSource>
//顶部输入框搜索
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)UITextField *inputtextFiled;
@property (nonatomic,strong)UITableView *mainTableView;
@property (nonatomic,strong)NSArray *dataArr;
@property (nonatomic,strong)NSMutableArray *searchArr;
@property (nonatomic,strong)SWTProgressHUD *hud;
@end

@implementation HomeIndustryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"行业选择";
    
    [self.view addSubview:[self topView]];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.hidden = YES;
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    if ([SWTReachability shareInstance].isNetworkReachable) { // 有网络
        
        _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载数据..."];
        
        [self requestData];
        
    } else { // 无网络
        [self showNoNetworkView];
    }
}

-(UIView *)topView{
    if (!_topView) {
        _topView  =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        _topView.backgroundColor = [UIColor hexStringToColor:@"#f6f7f9"];
        _inputtextFiled = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, kScreenWidth-20, 40)];
        _inputtextFiled.font = [UIFont systemFontOfSize:15];
        _inputtextFiled.textColor = [UIColor hexStringToColor:@"#333333"];
        _inputtextFiled.borderStyle = UITextBorderStyleRoundedRect;
        _inputtextFiled.placeholder = @"请输入您要搜索的行业";
        _inputtextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_inputtextFiled addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
        
        //文本框左视图
        UIView *leftView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
        leftView.backgroundColor = [UIColor clearColor];
        //添加图片
        UIImageView *headView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBig.png"]];
        [leftView addSubview:headView];
        [headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(leftView);
            make.right.equalTo(leftView);
        }];
        
        _inputtextFiled.leftView = leftView;
        //    图片显示的模式
        //    UITextFieldViewModeNever,
        //    UITextFieldViewModeWhileEditing,
        //    UITextFieldViewModeUnlessEditing,
        //    UITextFieldViewModeAlways
        _inputtextFiled.leftViewMode = UITextFieldViewModeAlways;
        [_topView addSubview:_inputtextFiled];
    }
    return _topView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

-(NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)searchArr
{
    if (!_searchArr) {
        _searchArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchArr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.inputtextFiled.text.length>0) {
        if (self.searchArr.count>0) {
            return self.searchArr.count;
        }else
        {
            return 0;
        }
    }
    
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    //重用机制
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 200, 21)];
        title.tag = 11;
        title.textColor = [UIColor hexStringToColor:@"#333333"];
        title.textAlignment = NSTextAlignmentLeft;
        title.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        [cell.contentView addSubview:title];
        
        UILabel *lineLabel = [[UILabel alloc]init];
        lineLabel.backgroundColor = [UIColor hexStringToColor:@"#E6E6E6"];
        [cell.contentView addSubview:lineLabel];
        
        [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(cell.contentView);
            make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
        }];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *title_label = [cell.contentView viewWithTag:11];
    if (self.searchArr.count>0) {
        title_label.text = self.searchArr[indexPath.row][@"CategoryName"];
    }else
    {
        title_label.text = self.dataArr[indexPath.row][@"CategoryName"];
    }
    
    return cell;
    
}
#pragma mark 回调监听
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(searchResult:)]) {
        if (self.searchArr.count>0) {
            [self.delegate searchResult:self.searchArr[indexPath.row][@"CategoryName"]];
        }else{
            [self.delegate searchResult:self.dataArr[indexPath.row][@"CategoryName"]];
        }
    }
    [self back];
}

- (void)searchChanged:(UITextField *)searchTF{
    [self.searchArr removeAllObjects];
    if (searchTF.text.length>0&&self.dataArr.count>0) {
        for (NSDictionary *dic in self.dataArr) {
            if ([[dic[@"CategoryName"] lowercaseString] containsString:[searchTF.text lowercaseString]]) {
                [self.searchArr addObject:dic];
            }
        }
    }
    [self.mainTableView reloadData];
}

#pragma mark 网络请求
- (void)requestData{
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Record/Categorys") parameters:nil usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        
        self.dataArr = dic[@"data"];
        self.mainTableView.hidden = NO;
        self.navigationItem.title = [NSString stringWithFormat:@"选择行业%lu",self.dataArr.count];
        [self.mainTableView reloadData];
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
         [self showErrorDataView];
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [self showErrorDataView];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.inputtextFiled resignFirstResponder];
}

- (void)keyboardSearchAction{
    
    [self.inputtextFiled resignFirstResponder];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

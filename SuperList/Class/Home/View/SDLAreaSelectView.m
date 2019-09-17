//
//  SDLAreaSelectView.m
//  SDL
//
//  Created by 胡定锋Mac on 2016/12/9.
//  Copyright © 2016年 胡定锋. All rights reserved.
//

#import "SDLAreaSelectView.h"
#import "UIColor+StringToColor.h"
#import "UILabel+Custom.h"
#import "Masonry.h"

@interface SDLAreaSelectView()
{
    int currentcellDisplayFlag;//当前tableView显示的数据是什么（省||市||区）
//    NSArray *provinceArr;
//    NSArray *cityArr;
    NSArray *dataArr;//省市区容器
    
    NSString *currentProvinceName;
    NSString *currentCityName;
    NSString *currentAreaName;//当前选择的省||市||区；
    int currentProvince;
    int currentCity;
    
}
@property (nonatomic,strong)UITableView *maintableView;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,strong)UIButton *provinceSelBtn;
@property (nonatomic,strong)UIButton *citySelBtn;
@property (nonatomic,strong)UIButton *areaSelBtn;

@property (nonatomic,strong)NSArray *addList;

@end

@implementation SDLAreaSelectView

-(instancetype)init
{
    if (self = [super init]) {
        [self customInit];
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight*2/3);
        _maintableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _maintableView.bounces = NO;
        _maintableView.delegate = self;
        _maintableView.dataSource = self;
        _maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_maintableView];
    }
    return self;
}

-(void)customInit{
    currentcellDisplayFlag = 0;
    
    dataArr = [NSArray array];
    self.addList = [NSArray array];
    
    currentProvinceName = [NSString string];
    currentCityName= [NSString string];
    currentAreaName= [NSString string];
    currentProvince = 0;
    currentCity = 0;
}

- (void)setName:(NSString *)p cityName:(NSString *)c
{
    currentProvinceName = p;
    currentCityName = c;
}

- (void)setAddressList:(NSArray *)addressList
{
    dataArr = addressList;
    self.addList = addressList;
    int number = (int)dataArr.count;//减少调用次数
    for (int i = 0; i < number; i++) {
        
        if ([dataArr[i][@"ProvinceName"] isEqualToString:currentProvinceName]) {
            currentProvince = i;
            break;
        }
    }
    NSLog(@"xxx%d",currentProvince);
    
    [_maintableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentProvince inSection:0];
    [_maintableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

-(UIView*)headerView{
    
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *linelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, -1, kScreenWidth, 1)];
        linelabel1.backgroundColor = [UIColor hexStringToColor:@"#E6E6E6"];
        [_headerView addSubview:linelabel1];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        titleLabel.backgroundColor = [UIColor hexStringToColor:@"#fafafa"];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor hexStringToColor:@"#333333"];
        titleLabel.text = @"所在地区";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:titleLabel];
        
        _provinceSelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _provinceSelBtn.tag = 1;
        _provinceSelBtn.frame = CGRectMake(10, 40, 80, 40);
        [_provinceSelBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        [_provinceSelBtn setTitleColor:[UIColor hexStringToColor:mColor_TopTarBg] forState:UIControlStateSelected];
        _provinceSelBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
        _provinceSelBtn.titleLabel.fixFontSize = YES;
        _provinceSelBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        _provinceSelBtn.hidden = NO;
        [_headerView addSubview:_provinceSelBtn];
        
        _citySelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _citySelBtn.tag = 2;
        _citySelBtn.frame = CGRectMake(90, 40, 80, 40);
        [_citySelBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        [_citySelBtn setTitleColor:[UIColor hexStringToColor:mColor_TopTarBg] forState:UIControlStateSelected];
        _citySelBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
        _citySelBtn.titleLabel.fixFontSize = YES;
        _citySelBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        _citySelBtn.hidden = YES;
        [_headerView addSubview:_citySelBtn];
        
        _areaSelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _areaSelBtn.tag = 3;
        _areaSelBtn.frame = CGRectMake(180, 40, 80, 40);
        [_areaSelBtn setTitleColor:[UIColor hexStringToColor:@"#333333"] forState:UIControlStateNormal];
        [_areaSelBtn setTitleColor:[UIColor hexStringToColor:mColor_TopTarBg] forState:UIControlStateSelected];
        _areaSelBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
        _areaSelBtn.titleLabel.fixFontSize = YES;
        _areaSelBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        _areaSelBtn.hidden = YES;
        [_headerView addSubview:_areaSelBtn];
        
        [_provinceSelBtn setTitle:@"请选择" forState:UIControlStateNormal];
        [_citySelBtn setTitle:@"请选择" forState:UIControlStateNormal];
        [_areaSelBtn setTitle:@"请选择" forState:UIControlStateNormal];
        _provinceSelBtn.selected = YES;
        
        [_provinceSelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_citySelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_areaSelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

        //取消按钮
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 40, 0, 40, 40)];
        [cancelBtn setImage:[UIImage imageNamed:@"goodsdetail_cancel"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:cancelBtn];
        
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _headerView.bounds.size.height-1, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor hexStringToColor:@"#E6E6E6"];
        [_headerView addSubview:lineLabel];
    }
    return _headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
     if (currentcellDisplayFlag == 0) {
         title_label.text = dataArr[indexPath.row][@"ProvinceName"];
         if ([currentProvinceName isEqualToString:dataArr[indexPath.row][@"ProvinceName"]]) {
             title_label.textColor = [UIColor hexStringToColor:mColor_TopTarBg];
         }else{
             title_label.textColor = [UIColor hexStringToColor:@"#333333"];
         }
     }else  if (currentcellDisplayFlag == 1) {
         title_label.text = dataArr[indexPath.row][@"CityName"];
         if ([currentCityName isEqualToString:dataArr[indexPath.row][@"CityName"]]) {
             title_label.textColor = [UIColor hexStringToColor:mColor_TopTarBg];
         }else{
             title_label.textColor = [UIColor hexStringToColor:@"#333333"];
         }
     }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio{
    
    return self.headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentcellDisplayFlag == 0) {
        currentProvinceName = dataArr[indexPath.row][@"ProvinceName"];
        //修改button
        [_provinceSelBtn setTitle:currentProvinceName forState:UIControlStateSelected];
        _citySelBtn.hidden = NO;
         dataArr = self.addList[indexPath.row][@"citys"];
        
        int number = (int)dataArr.count;//减少调用次数
        currentCity = 0;
        for (int i = 0; i < number; i++) {
            
            if ([dataArr[i][@"CityName"] isEqualToString:currentCityName]) {
                currentCity = i;
                break;
            }
        }
        
        if (currentCity == 0) {
            currentCityName = dataArr[0][@"CityName"];
        }
        
        currentcellDisplayFlag = 1;
        [_maintableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentCity inSection:0];
        [_maintableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        
    }
    else if (currentcellDisplayFlag == 1) {
        
        currentCityName = dataArr[indexPath.row][@"CityName"];
        [_citySelBtn setSelected:YES];
        [_citySelBtn setTitle:currentCityName forState:UIControlStateSelected];
        _areaSelBtn.hidden = NO;
        
        NSLog(@"%@/%@",currentProvinceName,currentCityName);
        
        if ([self.delegate respondsToSelector:@selector(finishedSelecteWith:areaData:)]) {
            [self.delegate finishedSelecteWith:[NSString stringWithFormat:@"%@-%@",currentProvinceName,currentCityName] areaData:@{@"currentProvinceName":currentProvinceName,
                                                                                                                                   @"currentCityName":currentCityName}];
        }
    }
    else if (currentcellDisplayFlag == 3) {
        
        currentAreaName = dataArr[indexPath.row][@"region_name"];
        [_areaSelBtn setSelected:YES];
        [_areaSelBtn setTitle:currentAreaName forState:UIControlStateSelected];
        NSLog(@"%@/%@/%@",currentProvinceName,currentCityName,currentAreaName);
        
        
        if ([self.delegate respondsToSelector:@selector(finishedSelecteWith:areaData:)]) {
            [self.delegate finishedSelecteWith:[NSString stringWithFormat:@"%@-%@",currentProvinceName,currentCityName] areaData:@{@"currentProvinceName":currentProvinceName,
                           @"currentCityName":currentCityName}];
        }
    }

}


-(void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int i = (int)button.tag;
    if (i == 1) {
        if (currentcellDisplayFlag == 0)
        {
            _provinceSelBtn.selected = YES;
            _citySelBtn.selected = NO;
            _areaSelBtn.selected = NO;
            _citySelBtn.hidden = YES;//
            _areaSelBtn.hidden = YES;//
            dataArr = self.addList;
            [_maintableView reloadData];
        }else{
            currentcellDisplayFlag = 0;
            _provinceSelBtn.selected = YES;
            _citySelBtn.selected = NO;
            _areaSelBtn.selected = NO;
            _citySelBtn.hidden = NO;//
            _areaSelBtn.hidden = YES;//
            dataArr = self.addList;
            [_maintableView reloadData];
        }
        
    }else{
        if (currentcellDisplayFlag == 1 ||currentcellDisplayFlag == 0||currentcellDisplayFlag == 2) {
//            _provinceSelBtn.hidden = NO;
//            _citySelBtn.hidden = NO;
//            _areaSelBtn.hidden = YES;
            return;
        }
        if (i==2) {
            currentcellDisplayFlag = 2;
            _provinceSelBtn.selected = YES;
            _citySelBtn.selected = YES;
            _areaSelBtn.selected = NO;
            
            _provinceSelBtn.hidden = NO;
            _citySelBtn.hidden = NO;
            _areaSelBtn.hidden = NO;
        }
    }
}

-(void)dismiss{
    if ([self.delegate respondsToSelector:@selector(selectviewDismissed)]) {
        [self.delegate selectviewDismissed];
    }
}
@end

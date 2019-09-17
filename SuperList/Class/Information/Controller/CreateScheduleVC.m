//
//  CreateScheduleVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/12.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "CreateScheduleVC.h"
#import "Masonry.h"
#import "SWTTimeUtils.h"
#import "MyTaskModel.h"

@interface CreateScheduleVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) UITextField *tfTitle;

@property (nonatomic, strong) UILabel *labSelectTime;

#pragma mark 时间选择弹出框
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIDatePicker *datePicker;

#pragma mark 是否提醒
@property (nonatomic, strong) UISwitch *switchRemind;
@end

@implementation CreateScheduleVC
{
    CGFloat _btnH;
    NSDate *_selectedDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    _btnH = 50;
    if (self.taskModel) {
        self.navigationItem.title = @"编辑日程";
    }else
    {
         self.navigationItem.title = @"创建日程";
    }
    
    [self setUpView];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}
- (void)setUpView{
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, Main_Screen_Height - _btnH - 64, Main_Screen_Width, _btnH);
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [submitBtn setTitle:@"保存" forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
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

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        CGFloat padding = 10;
        CGFloat bgHeight = 44;
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        UITextField *tfTitle = [[UITextField alloc] init];
        self.tfTitle = tfTitle;
        tfTitle.placeholder = @"请输入事项";
        
        tfTitle.backgroundColor = [UIColor whiteColor];
        tfTitle.font = FONT(14);
        tfTitle.textColor = [UIColor hexStringToColor:@"#333333"];
        // 设置清除模式
        tfTitle.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        //设置左边视图的宽度
        tfTitle.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, padding, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        tfTitle.leftViewMode = UITextFieldViewModeAlways;
        [_tableHeaderView addSubview:tfTitle];
        
        [tfTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_tableHeaderView);
            make.height.mas_equalTo(bgHeight);
        }];
        
        // 日程时间
        UIView *bgTime = [[UIView alloc] init];
        bgTime.backgroundColor = [UIColor whiteColor];
        bgTime.userInteractionEnabled = YES;
        [_tableHeaderView addSubview:bgTime];
        
        [bgTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_tableHeaderView);
            make.top.equalTo(tfTitle.mas_bottom).offset(padding);
            make.height.mas_equalTo(bgHeight);
        }];
        
        UILabel *labTime = [[UILabel alloc] init];
        labTime.text = @"日程时间";
        labTime.font = FONT(14);
        labTime.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgTime addSubview:labTime];
        
        [labTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(bgTime).offset(padding);
            make.centerY.equalTo(bgTime);
        }];
        
        
        UILabel *labSelectTime = [[UILabel alloc] init];
        self.labSelectTime = labSelectTime;
        labSelectTime.userInteractionEnabled = YES;
        labSelectTime.text = @"请选择日期";
        labSelectTime.tag = 1000;
        labSelectTime.textAlignment = NSTextAlignmentRight;
        labSelectTime.font = FONT(14);
        labSelectTime.textColor = [UIColor hexStringToColor:@"#666666"];
        [bgTime addSubview:labSelectTime];
        [labSelectTime addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickAction:)]];
        [labSelectTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgTime).offset(padding);
            make.right.equalTo(bgTime).offset(-padding);
            make.centerY.equalTo(bgTime);
        }];
        
        
        // 日程时间
        UIView *bgRemind = [[UIView alloc] init];
        bgRemind.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:bgRemind];
        bgRemind.userInteractionEnabled = YES;
        [bgRemind mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_tableHeaderView);
            make.top.equalTo(bgTime.mas_bottom).offset(padding);
            make.height.mas_equalTo(bgHeight);
        }];
        
        UILabel *labRemind = [[UILabel alloc] init];
        labRemind.text = @"是否需要提醒";
        labRemind.font = FONT(14);
        labRemind.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgRemind addSubview:labRemind];
        
        [labRemind mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(bgRemind).offset(padding);
            make.centerY.equalTo(bgRemind);
        }];
        
        
        
        
        UISwitch *switchRemind = [[UISwitch alloc] init];

        self.switchRemind = switchRemind;
        switchRemind.on = YES;//设置初始为ON的一边
        [switchRemind addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];   // 开关事件切换通知
        [bgRemind addSubview:switchRemind];
        
        [switchRemind mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgRemind).offset(-padding);
            make.centerY.equalTo(bgRemind);
        }];
        
        //由于Masonry.h  不能立即通过约束转变成frame
        [_tableHeaderView layoutIfNeeded];
        _tableHeaderView.height = CGRectGetMaxY(bgRemind.frame)+padding;
        
        
        if (self.taskModel) {
            tfTitle.text = self.taskModel.TaskText;
            labSelectTime.text = self.taskModel.TaskTime;
            
            if ([self.taskModel.IsClock intValue] == 1) {
                switchRemind.on = YES;
            }else
            {
                switchRemind.on = NO;
            }
        }
        
    }
    return _tableHeaderView;
}

#pragma mark 时间选择事件

- (void)ClickAction:(UITapGestureRecognizer *)tapGesture{
    UIView *view = tapGesture.view;
    NSInteger tag = view.tag;
    if (tag == 1000) { // 时间选择
        
        [self.view endEditing:YES];
        [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
        [UIView animateWithDuration:0.25 animations:^{
            self.datePicker.y = Main_Screen_Height - 250;
        }];
        
    }
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        NSLog(@"开");
    }else {
        NSLog(@"关");
    }
}

#pragma mark 提交资料
- (void)submitAction:(id)sender{
    
    if ([self.tfTitle.text length] == 0) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请输入事项"];
        return;
    }
    if ([self.labSelectTime.text length] == 0 || [self.labSelectTime.text isEqualToString:@"请选择日期"]) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请选择日程时间"];
        return;
    }
    
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中.."];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"tasktext"] = self.tfTitle.text;
    paramesDic[@"tasktime"] = self.labSelectTime.text;
    if ([self.switchRemind isOn]) {
        paramesDic[@"isclock"] = @"1";
    }else
    {
        paramesDic[@"isclock"] = @"0";
    }
    
    NSString *strUrl = @"api/Task/Create";
    if (self.taskModel) {
        paramesDic[@"id"] = self.taskModel.Id;
        strUrl = @"api/Task/ModifyTask";
    }
    
    
    [[RequestInstance shareInstance] POST:GETAPIURL(strUrl) parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    } unusableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"操作失败请重试"];
    }];
}


#pragma mark - lazy load

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark 和时间选择相关

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewDismiss)]];
        [_maskView addSubview:self.datePicker];
    }
    return _maskView;
}

- (UIDatePicker *)datePicker{
    if (!_datePicker) {
        CGFloat datePickerH = 250;
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, Main_Screen_Height, Main_Screen_Width, datePickerH)];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.backgroundColor = [UIColor whiteColor];
    }
    return _datePicker;
}

- (void)maskViewDismiss{
    [self setValueFromDatePicker:_datePicker.date];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.datePicker.y = Main_Screen_Height;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

- (void)setValueFromDatePicker:(NSDate *)date{
    
    _selectedDate = date;
    self.labSelectTime.text = [SWTTimeUtils formatDate:date format:@"yyyy-MM-dd HH:mm"];
}

- (NSString *)textFromDate:(NSDate *)date{
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger year = dateComponents.year;
    NSInteger month = dateComponents.month;
    NSInteger day = dateComponents.day;
    NSInteger hour = dateComponents.hour;
    NSInteger minute = dateComponents.minute;
    
    NSString *noonStr;
    NSInteger noonHour;
    if ((hour - 12) > 0) {
        noonStr = @"下午";
        noonHour = hour - 12;
    } else {
        noonStr = @"上午";
        noonHour = hour;
    }
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld年%ld月%ld日 %@%ld:%ld",year, month, day, noonStr, noonHour, minute];
    
    return dateStr;
}

- (NSDate *)getNowDateFromAnDate:(NSDate *)anyDate{
    /*
     // 设置源日期时间
     NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
     // 设置转换后的目标日期时区
     NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
     // 得到源日期与世界标准时间的偏移量
     NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
     // 目标日期与本地时区的偏移量
     NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
     // 得到时间偏移量的差值
     NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
     // 转为现在时间
     NSDate *destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
     return destinationDateNow;
     */
    return anyDate;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

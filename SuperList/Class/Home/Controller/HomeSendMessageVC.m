//
//  HomeSendMessageVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/6.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "HomeSendMessageVC.h"
#import "FlagsLayoutView.h"
#import "HomePageCell.h"
#import "SZTextView.h"
#import "Masonry.h"
#import <MessageUI/MessageUI.h>
#import "SWTProgressHUD.h"

@interface HomeSendMessageVC ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) FlagsLayoutView *flags;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableHeaderView;

@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSMutableArray *dataArrMessage;

@property (nonatomic, strong) NSMutableArray *dataArrFlags;
@property (nonatomic, strong) NSString *strMessage;

@property (nonatomic, strong) UILabel *labMessageContentTiShi;

@property (nonatomic, strong) SZTextView *textView;
//普通的等待框
@property (nonatomic, strong) SWTProgressHUD *hud;

@end

static NSString * HomePageCellID = @"HomePageCellID";


@implementation HomeSendMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群发短信";
    self.view.backgroundColor = [UIColor whiteColor];
    [self requestData];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}
- (void)setMessage:(NSString *)message
{
    self.strMessage = message;
    self.dataArrFlags = [[message componentsSeparatedByString:@","] mutableCopy];
}
#pragma mark - lazy load

//列表顶部视图
- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:HomePageCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = self.tableFooterView;
    }
    return _tableView;
}
-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        CGFloat padding = 10;
        
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:self.flags];
        
        CGFloat flagsHeight = self.flags.frame.size.height+2*padding;
        
        CGFloat vMessageContentHeight = 40.0f;
        UIView *vMessageContentBg = [[UIView alloc] initWithFrame:CGRectMake(0, flagsHeight, kScreenWidth, vMessageContentHeight)];
        
        [_tableHeaderView addSubview:vMessageContentBg];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, flagsHeight, kScreenWidth, 0.5)];
        line1.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [_tableHeaderView addSubview:line1];
        
        UILabel *labMessageContent = [[UILabel alloc] init];
        labMessageContent.textColor = [UIColor hexStringToColor:@"#666666"];
        labMessageContent.font = FONT(12);
        labMessageContent.text = @"短信内容";
        [vMessageContentBg addSubview:labMessageContent];
        [labMessageContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vMessageContentBg).mas_offset(10);
            make.centerY.equalTo(vMessageContentBg);
        }];
        
        
        UILabel *labMessageContentTiShi = [[UILabel alloc] init];
        labMessageContentTiShi.textColor = [UIColor hexStringToColor:@"#666666"];
        labMessageContentTiShi.font = FONT(12);
        
        labMessageContentTiShi.text = @"0/70";
        [vMessageContentBg addSubview:labMessageContentTiShi];
        self.labMessageContentTiShi = labMessageContentTiShi;
        [labMessageContentTiShi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(vMessageContentBg).mas_offset(-10);
            make.centerY.equalTo(vMessageContentBg);
        }];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, flagsHeight+vMessageContentHeight, kScreenWidth, 0.5)];
        line2.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
         [_tableHeaderView addSubview:line2];
        
        
        CGFloat textViewHeight = 120;
        self.textView = [[SZTextView alloc] init];
        self.textView.placeholder = @"请输入你要发送的短信";
        self.textView.delegate = self;
        CGFloat inset = 15.0;
        // ios 7
        if ([UITextView instancesRespondToSelector:@selector(setTextContainerInset:)]) {
            self.textView.textContainerInset = UIEdgeInsetsMake(inset, inset, inset, inset);
        } else {
            self.textView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset);
        }
        
        [_tableHeaderView addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_tableHeaderView);
            make.top.equalTo(line2.mas_bottom);
            make.height.mas_equalTo(textViewHeight);
        }];
        
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, flagsHeight+vMessageContentHeight+textViewHeight, kScreenWidth, 0.5)];
        line3.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [_tableHeaderView addSubview:line3];
        
        _tableHeaderView.height = flagsHeight + vMessageContentHeight + textViewHeight;
        
    }
    return _tableHeaderView;
}

-(FlagsLayoutView *)flags
{
    if (!_flags) {
        self.flags = [[FlagsLayoutView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 0)];
        self.flags.BigBGColor = [UIColor hexStringToColor:@"#e1e2e1"];
        [self.flags setTagWithTagArray:self.dataArrFlags];
    }
    return _flags;
}

//列表底部视图
- (UIView *)tableFooterView
{
    if (!_tableFooterView) {
        _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        CGFloat footerHeight = 10;
        
        CGFloat padding = 10;
        CGFloat vSpacing = 10.0f;
        CGFloat hSpacing = 20.0f;
        CGFloat itemWidth = (kScreenWidth-2*padding-3*hSpacing)/3;
        CGFloat itemHeight = 30.0f;
        
        for (int i=0; i<[self.dataArrMessage count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            btn.frame = CGRectMake(padding+i%4*(itemWidth+hSpacing),footerHeight+ i/4*(itemHeight+vSpacing)+padding, itemWidth, itemHeight);
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitle:[NSString stringWithFormat:@"短信模板%d",i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor hexStringToColor:@"#666666"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(fillContent:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = FONT(13);
            btn.layer.cornerRadius = 4.0;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor hexStringToColor:@"#e1e2e1"].CGColor;
            [_tableFooterView addSubview:btn];
            if (i == 0) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor hexStringToColor:@"#e1e2e1"];
                self.textView.text = self.dataArrMessage[i][@"Text"];
                
                self.labMessageContentTiShi.text = [NSString stringWithFormat:@"%lu/70",self.textView.text.length];
            }
        }
        
        if ([self dataArrMessage].count/4 == 0) {
            footerHeight = footerHeight +padding +([self dataArrMessage].count/4+1)*(itemHeight+vSpacing);
        }else if ([self dataArrMessage].count%4 == 0) {
            footerHeight = footerHeight +padding +([self dataArrMessage].count/4)*(itemHeight+vSpacing);
        }else  {
            footerHeight = footerHeight +padding +([self dataArrMessage].count/4+1)*(itemHeight+vSpacing);
        }
        
        CGFloat vbtnHeight = 40.0f;
        UIButton *btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSendMessage.frame = CGRectMake(10, footerHeight, kScreenWidth-20, vbtnHeight);
        btnSendMessage.backgroundColor = [UIColor hexStringToColor:mColor_TopTarBg];
        [btnSendMessage setTitle:@"发送" forState:UIControlStateNormal];
        [btnSendMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSendMessage addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        btnSendMessage.titleLabel.font = FONT(16);
        btnSendMessage.layer.cornerRadius = 4.0;
        [_tableFooterView addSubview:btnSendMessage];
        
        footerHeight = footerHeight+vbtnHeight;
        
        NSDictionary *dict = @{NSFontAttributeName : FONT(13)};
        NSString *contentStr=@"系统将调用您手机的短信发送功能发送短信，请按照国家相关法律要求操作。本系统只提供客户联系方式和模板服务。如果需要平台代发短信，请联系客服。";
        CGSize size=[contentStr boundingRectWithSize:CGSizeMake(kScreenWidth-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        UILabel *labTiShi=[[UILabel alloc]init];
        labTiShi.font=FONT(13);
        labTiShi.numberOfLines = 0;
        labTiShi.text =contentStr;
        labTiShi.textColor = [UIColor hexStringToColor:@"#666666"];
        labTiShi.frame = CGRectMake(10, footerHeight+padding, kScreenWidth-20, size.height);
        [_tableFooterView addSubview:labTiShi];
        
        footerHeight = footerHeight + padding + size.height;
        
        _tableFooterView.height = footerHeight;
    }
    return _tableFooterView;
}

#pragma mark 网络请求
- (void)requestData
{
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"请稍等"];
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Sms/Modles") parameters:nil usableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        self.dataArrMessage = dic[@"data"];
        
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.view);
        }];
        
    } unusableStatus:^(NSDictionary *dic) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        if (_hud) {
            [_hud hideAnimated:YES];
        }
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];
    }];
}

- (void)requestDataUpdate
{
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"revmobiles"] = self.strMessage;
    paramesDic[@"text"] = self.textView.text;
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/Sms/UploadData") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        
        
    } unusableStatus:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
}

#pragma mark 发送短信
- (void)sendMessage{
    if([MFMessageComposeViewController canSendText])
    {
        [self displaySMSComposerSheetPhoneNumber];
    }
    else
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持发短信" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
    }
}

-(void)displaySMSComposerSheetPhoneNumber
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
//    picker.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
    picker.messageComposeDelegate = self;
    picker.recipients = [NSArray arrayWithArray:self.dataArrMessage];
    
    picker.body = self.textView.text;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark 改变短信内容

- (void)fillContent:(UIButton *)btn
{
    int bTag = (int)[btn tag];
    for (int i = 0; i<self.dataArrMessage.count; i++) {
        UIButton *myButton = (UIButton *)[self.view viewWithTag:(100+i)];
        if (bTag == (100+i)) {
            myButton.selected = YES;
            myButton.backgroundColor = [UIColor hexStringToColor:@"#e1e2e1"];
            self.textView.text = self.dataArrMessage[i][@"Text"];
             self.labMessageContentTiShi.text = [NSString stringWithFormat:@"%lu/70",self.textView.text.length];
        }else
        {
            myButton.selected = NO;
            myButton.backgroundColor = [UIColor whiteColor];
        }
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    // 关闭短信界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(result == MessageComposeResultCancelled) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"取消发送"];
    } else if(result == MessageComposeResultSent) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"已经发出"];
        
        [self requestDataUpdate];
        
    } else {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"发送失败"];
    }
}

#pragma  mark 监听输入的内容
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    self.labMessageContentTiShi.text = [NSString stringWithFormat:@"%ld/70",existTextNum];
    
}


- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (NSMutableArray *)dataArrMessage{
    if (!_dataArrMessage) {
        _dataArrMessage = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArrMessage;
}


- (NSMutableArray *)dataArrFlags{
    if (!_dataArrFlags) {
        _dataArrFlags = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArrFlags;
}

#pragma mark UITableViewDataSource && UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:HomePageCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HomeQueryModel *model = _dataArr[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

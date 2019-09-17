//
//  WantToPromoteVC.m
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "WantToPromoteVC.h"
#import "Masonry.h"
#import "SWTProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface WantToPromoteVC ()<UITableViewDelegate,UITableViewDataSource,
                        UIActionSheetDelegate,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIImageView *cardFrontImageView;
@property (nonatomic, strong) UITextField *tfTitle;
@property (nonatomic, strong) UITextField *tfPhone;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation WantToPromoteVC
{
    CGFloat _btnH;
    NSString *_urlImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我要推广";
    self.view.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
    _btnH = 50;
    _urlImage = @"";
    
    [self setUpView];
}

- (void)setUpView{
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, Main_Screen_Height - _btnH - 64, Main_Screen_Width, _btnH);
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
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
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        CGFloat bgTuiGuangHeight = 88;
        // 推广标题
        UIView *bgTuiGuang = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, bgTuiGuangHeight)];
        bgTuiGuang.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:bgTuiGuang];
        
        UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, kScreenWidth-2*padding, bgTuiGuangHeight/2)];
        labTitle.text = @"推广标题";
        labTitle.font = FONT(14);
        labTitle.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgTuiGuang addSubview:labTitle];
        
        UITextField *tfTitle = [[UITextField alloc] initWithFrame:CGRectMake(padding, bgTuiGuangHeight/2, kScreenWidth-2*padding, bgTuiGuangHeight/2)];
        self.tfTitle = tfTitle;
        tfTitle.placeholder = @"请输入推广标题";
        tfTitle.font = FONT(14);
        tfTitle.textColor = [UIColor hexStringToColor:@"#666666"];
        // 设置清除模式
        tfTitle.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        [bgTuiGuang addSubview:tfTitle];
        
        UIView *lineTitle = [[UIView alloc] initWithFrame:CGRectMake(padding, bgTuiGuangHeight/2, kScreenWidth-2*padding, 0.5)];
        lineTitle.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [bgTuiGuang addSubview:lineTitle];
        
        
        
        // 联系方式
        CGFloat bgPhoenHeight = bgTuiGuangHeight+padding;
        UIView *bgPhone = [[UIView alloc] initWithFrame:CGRectMake(0, bgPhoenHeight, kScreenWidth, bgTuiGuangHeight)];
        bgPhone.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:bgPhone];
        
        UILabel *labPhone = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, kScreenWidth-2*padding, bgTuiGuangHeight/2)];
        labPhone.text = @"联系方式";
        labPhone.font = FONT(14);
        labPhone.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgPhone addSubview:labPhone];
        
        UITextField *tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(padding, bgTuiGuangHeight/2, kScreenWidth-2*padding, bgTuiGuangHeight/2)];
        self.tfPhone = tfPhone;
        tfPhone.placeholder = @"请输入联系方式";
        tfPhone.font = FONT(14);
        // 键盘模式
        tfPhone.keyboardType = UIKeyboardTypePhonePad; //键盘模式
        // 设置清除模式
        tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;// 设置清除模式
        
        tfPhone.textColor = [UIColor hexStringToColor:@"#666666"];
        
        [bgPhone addSubview:tfPhone];
        
        UIView *linePhone = [[UIView alloc] initWithFrame:CGRectMake(padding, bgTuiGuangHeight/2, kScreenWidth-2*padding, 0.5)];
        linePhone.backgroundColor = [UIColor hexStringToColor:mColor_MainBg];
        [bgPhone addSubview:linePhone];
        
        
        // 上次图片
        CGFloat bgUpdateHeight = 2*(bgTuiGuangHeight+padding);
        UIView *bgUpdata = [[UIView alloc] initWithFrame:CGRectMake(0, bgUpdateHeight, kScreenWidth, bgTuiGuangHeight/2)];
        bgUpdata.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:bgUpdata];
        
        UILabel *labUpdata = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, kScreenWidth-2*padding, bgTuiGuangHeight/2)];
        labUpdata.text = @"上传推广图片";
        labUpdata.font = FONT(14);
        labUpdata.textColor = [UIColor hexStringToColor:@"#333333"];
        [bgUpdata addSubview:labUpdata];
        
        CGFloat imageViewHeight = 2*(bgTuiGuangHeight+padding) + bgTuiGuangHeight/2 + padding;
        
        UIView *imageViewBg = [[UIView alloc] initWithFrame:CGRectMake(padding, imageViewHeight, 100, 100)];
        imageViewBg.userInteractionEnabled = YES;
        imageViewBg.backgroundColor = [UIColor whiteColor];
        imageViewBg.clipsToBounds = YES;
        [imageViewBg.layer setCornerRadius:5];
        imageViewBg.layer.shouldRasterize = YES;
        imageViewBg.layer.borderColor = [UIColor hexStringToColor:@"#e2e2e2"].CGColor;
        imageViewBg.layer.borderWidth = 0.5;
        [_tableHeaderView addSubview:imageViewBg];
        
        UIImageView *iconXiangJi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xiangji"]];
        [imageViewBg addSubview:iconXiangJi];
        [iconXiangJi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(imageViewBg);
        }];
        
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageViewBg addSubview:imageView];
        imageView.tag = 1000;
        imageView.clipsToBounds = YES;
        [imageView.layer setCornerRadius:5];
        imageView.userInteractionEnabled = YES;
        self.cardFrontImageView = imageView;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickAction:)]];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(imageViewBg);
        }];
        
        _tableHeaderView.height = 2*(bgTuiGuangHeight+padding) + bgTuiGuangHeight/2 +padding +100;
        
    }
    return _tableHeaderView;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}
#pragma  mark 照片上传
- (void)ClickAction:(UITapGestureRecognizer *)tapGesture{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        // 拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该设备不支持摄像机拍照" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }
    
    if (buttonIndex == 1) {
        // 相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该设备不支持图库" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = sourceType;
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(theImage,0.5);
        [self.cardFrontImageView setImage:theImage];
        [self uploadImageWithImageData:imageData image:theImage picker:picker];
    }
}

#pragma mark 上传图片
- (void)uploadImageWithImageData:(NSData *)imageData image:(UIImage *)image picker:(UIImagePickerController *)picker{
    
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中.."];
    
    [[RequestInstance shareInstance] uploadimageName:[NSString stringWithFormat:@"%@.jpg",[self getOneUUID]] imageData:imageData url:GETAPIURL(@"api/BusinessShare/Upload") dealWithBlock:^(NSDictionary *dict, NSError *error) {
        [hud hideAnimated:YES];
        if (!error) {
            
            if([dict[@"status"] intValue] == 0){
                
                [picker dismissViewControllerAnimated:YES completion:nil];
                _urlImage = dict[@"data"][@"message"];
            }else{
                [picker dismissViewControllerAnimated:YES completion:nil];
                
                [SWTProgressHUD toastMessageAddedTo:self.view message:dict[@"message"]];
            }
        }else{
            
            [picker dismissViewControllerAnimated:YES completion:nil];
            [SWTProgressHUD toastMessageAddedTo:self.view message:@"请检查网络连接"];
        }
    }];
}

#pragma mark 提交资料
- (void)submitAction:(id)sender{
    
    if ([self.tfTitle.text length] == 0) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"推广标题不能为空"];
        return;
    }
    if ([self.tfPhone.text length] == 0) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"联系方式不能为空"];
        return;
    }
    
    if (_urlImage == nil || [_urlImage isEqualToString:@""]) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"推广图片必须上传"];
        return;
    }
    
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中.."];
    
    NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
    paramesDic[@"picture"] = _urlImage;
    paramesDic[@"text"] = self.tfTitle.text;
    paramesDic[@"tel"] = self.tfPhone.text;
    
    [[RequestInstance shareInstance] POST:GETAPIURL(@"api/BusinessShare/Apply") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:KEYWINDOW message:dic[@"data"][@"message"]];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    } unusableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"上传失败请重试"];
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

-(NSString *)getOneUUID{
    CFUUIDRef puuid=CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (__bridge_transfer NSString *)CFStringCreateCopy(NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

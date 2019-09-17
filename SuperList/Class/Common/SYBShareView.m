//
//  SYBShareView.m
//  SuperList
//
//  Created by SWT on 2017/11/23.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SYBShareView.h"
#import "SYBShareModel.h"
#import "UIColor+StringToColor.h"
#import "UMShare.h"
#import "SWTProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "RequestInstance.h"

#define SYBShareViewH 274

@interface SYBShareView()

@property (nonatomic, strong) UIView *maskView;

@end

@implementation SYBShareView

+ (instancetype)shareViewWithModel:(SYBShareModel *)shareModel{
    SYBShareView *shareView = [[SYBShareView alloc] initWithModel:shareModel];
    return shareView;
}

- (instancetype)initWithModel:(SYBShareModel *)shareModel{
    if (self = [super init]) {
        _shareModel = shareModel;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    
    self.backgroundColor = [UIColor hexStringToColor:@"#e6e6e6"];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat edge = 15;
    CGFloat buttonW = 60;
    CGFloat buttonTitleH = 20;
    CGFloat interSpace = ((screenW - edge * 2) - buttonW * 4) / 3;
    
    self.frame = CGRectMake(0, screenH, screenW, SYBShareViewH);
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(edge, 0, screenW - edge * 2, 44.0f)];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.text = @"分享至";
    titleLab.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLab];
    
    NSArray *btnImages = @[@"shareView_wechat", @"shareView_moments", @"shareView_qq", @"shareView_qqZone",@"shareView_weibo",@"shareView_message",@"shareView_link"];
    NSArray *btnTitles = @[@"微信", @"朋友圈", @"QQ好友", @"QQ空间",@"微博",@"短信",@"链接"];
    
    for (int i = 0; i < btnImages.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *buttonLab = [[UILabel alloc] init];
        buttonLab.text = btnTitles[i];
        buttonLab.font = [UIFont  systemFontOfSize:13];
        buttonLab.backgroundColor = [UIColor clearColor];
        buttonLab.textAlignment = NSTextAlignmentCenter;
        buttonLab.tag = 400 + i;
        
        [self addSubview:button];
        [self addSubview:buttonLab];
        
        if (i < 4) {
            button.frame = CGRectMake(edge + i * (buttonW + interSpace), CGRectGetMaxY(titleLab.frame), buttonW, buttonW);
            buttonLab.frame = CGRectMake(button.frame.origin.x, CGRectGetMaxY(button.frame), buttonW, buttonTitleH);
        } else {
            UIView *topView = [self viewWithTag:(400 + i - 4)];
            button.frame = CGRectMake(edge + (i - 4) * (buttonW + interSpace), CGRectGetMaxY(topView.frame) + 6, buttonW, buttonW);
            buttonLab.frame = CGRectMake(button.frame.origin.x, CGRectGetMaxY(button.frame), buttonW, buttonTitleH);
        }
    }
    
    UIView *tempView = [self viewWithTag:(400 + btnTitles.count - 1)];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(tempView.frame) + 12, self.frame.size.width, 50);
    cancelBtn.backgroundColor = [UIColor hexStringToColor:@"#f5f5f5"];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor hexStringToColor:@"#646464"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
}

- (void)shareAction:(UIButton *)shareBtn{
    [self hideAnimated:YES];
    
    if (_shareModel) {
        
        int shareType = 0;
        UIButton *btn = (UIButton *)shareBtn;
        switch (btn.tag) {
            case 100: // 微信
            {
                BOOL isInstalled = [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession];
                if (!isInstalled) {
                    [SWTProgressHUD toastMessageAddedTo:nil message:@"请安装微信客户端"];
                    return;
                }
                shareType = UMSocialPlatformType_WechatSession;
                
            
            }
            break;
            
            case 101: // 微信朋友圈
            {
                BOOL isInstalled = [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession];
                if (!isInstalled) {
                    [SWTProgressHUD toastMessageAddedTo:nil message:@"请安装微信客户端"];
                    return;
                }
                shareType = UMSocialPlatformType_WechatTimeLine;
           
            }
            break;
            
            case 102: // qq好友
            {
                BOOL isInstalled =  [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ];
                if (!isInstalled) {
                    [SWTProgressHUD toastMessageAddedTo:nil message:@"请安装QQ客户端"];
                    return;
                }
                shareType = UMSocialPlatformType_QQ;
            }
            break;
            
            case 103: // qq空间
            {
                BOOL isInstalled =  [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ];
                if (!isInstalled) {
                    [SWTProgressHUD toastMessageAddedTo:nil message:@"请安装QQ客户端"];
                    return;
                }
                shareType = UMSocialPlatformType_Qzone;
                
            }
            break;
            
            case 104:{ // 新浪微博

                shareType = UMSocialPlatformType_Sina;

            }
            break;
            case 105:{ // 短信
                shareType = UMSocialPlatformType_Sms;

            }
            break;
            
            case 106:{
               // 复制链接
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = _shareModel.ShareAppUrl;
                [SWTProgressHUD toastMessageAddedTo:nil message:@"复制成功"];
                return;
            }
            break;
            
            case 107:{ // 支付宝
                BOOL isInstalled =  [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_AlipaySession];
                if (!isInstalled) {
                    [SWTProgressHUD toastMessageAddedTo:nil message:@"请安装支付宝客户端"];
                    return;
                }
                shareType = UMSocialPlatformType_AlipaySession;
            }
            break;
            
            default:
            break;
        }
        
        // 创建分享消息
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        NSString *thumbURL;
        if (_shareModel.ShareAppLogo && _shareModel.ShareAppLogo.length) {
            thumbURL = _shareModel.ShareAppLogo;
        } else {
            thumbURL = @"https://www.SuperList.com/style/app/logo_114.png";
        }
        
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:_shareModel.ShareAppTitle descr:_shareModel.ShareAppTrip thumImage:thumbURL];
        
        if (shareType == UMSocialPlatformType_Sms) {
            shareObject.webpageUrl = [NSString stringWithFormat:@"%@%@",_shareModel.ShareAppTrip, _shareModel.ShareAppUrl];
        } else {
            shareObject.webpageUrl = _shareModel.ShareAppUrl;
        }
        
        messageObject.shareObject = shareObject;
        
        // 调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:_rootViewController completion:^(id data, NSError *error) {
            if (!error) {
                if ([data isKindOfClass:[UMSocialShareResponse class]]) {

                    [SWTProgressHUD toastMessageAddedTo:_rootViewController.view message:@"分享成功"];
                    
                }
            }
        }];
        NSMutableDictionary *paramesDic = [NSMutableDictionary dictionary];
        paramesDic[@"sharetype"] = [NSString stringWithFormat:@"%d",shareType];
        [[RequestInstance shareInstance] POST:GETAPIURL(@"api/AppSetting/Share") parameters:paramesDic usableStatus:^(NSDictionary *dic) {
            
            
        } unusableStatus:^(NSDictionary *dic) {
            
        } error:^(NSError *error) {
            
        }];
    }
        
}

- (void)show{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
//    self.frame = CGRectMake(0, screenH, screenW, SYBShareViewH);
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 1.0;
        self.frame = CGRectMake(0, screenH - SYBShareViewH, screenW, SYBShareViewH);
    }];
}

- (void)hideAnimated:(BOOL)animated{
    _rootViewController = nil;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, SYBShareViewH);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.maskView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.maskView removeFromSuperview];
                [self removeFromSuperview];  
            }];
        }];
    } else {
        [self.maskView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)cancel{
    [self hideAnimated:YES];
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.40];
        _maskView.alpha = 0.0f;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapGesture:)];
        tapGesture.numberOfTapsRequired = 1; //点击次数
        tapGesture.numberOfTouchesRequired = 1; //点击手指数
        [_maskView addGestureRecognizer:tapGesture];
    }
    return _maskView;
}

- (void)maskViewTapGesture:(UITapGestureRecognizer *)tapGesture{
    [self hideAnimated:YES];
}

@end

//
//  FeedBackVC.m
//  SuperList
//
//  Created by hdf on 2016/10/19.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import "FeedBackVC.h"
#import <sys/utsname.h>
#import "SWTProgressHUD.h"
#import "RequestInstance.h"
#import "SYBLocalDefine.h"
#import "SZTextView.h"

@interface FeedBackVC ()<UITextViewDelegate,UIAlertViewDelegate,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *maintableView;
@property (weak, nonatomic) IBOutlet SZTextView *textView;
@end

@implementation FeedBackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    self.textView.delegate = self;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor hexStringToColor:mColor_MainBg].CGColor;
    self.maintableView.delegate = self;
    CGFloat inset = 15.0;
    // ios 7
    if ([UITextView instancesRespondToSelector:@selector(setTextContainerInset:)]) {
        self.textView.textContainerInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    } else {
        self.textView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

+  (NSString*)deviceModelName {
    /*
     @"i386"      on the simulator
     @"x86_64"    on the simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPod5,1"   on iPod Touch Fourth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPad2,5"   on iPad mini 1
     @"iPad3,1"   on iPad 3
     @"iPhone3,1" on iPhone 4
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5
     */
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if([modelName isEqualToString:@"i386"] || [modelName isEqualToString:@"x86_64"]) {
        modelName = @"iPhone Simulator";
    }
    else if([modelName isEqualToString:@"iPhone1,1"]) {
        modelName = @"iPhone";
    }
    else if([modelName isEqualToString:@"iPhone1,2"]) {
        modelName = @"iPhone 3G";
    }
    else if([modelName isEqualToString:@"iPhone2,1"]) {
        modelName = @"iPhone 3GS";
    }
    else if([modelName isEqualToString:@"iPhone3,1"]) {
        modelName = @"iPhone 4";
    }
    else if([modelName isEqualToString:@"iPhone3,2"]) {
        modelName = @"iPhone 4";
    }
    else if([modelName isEqualToString:@"iPhone3,3"]) {
        modelName = @"iPhone 4";
    }
    else if([modelName isEqualToString:@"iPhone4,1"]) {
        modelName = @"iPhone 4S";
    }
    else if([modelName isEqualToString:@"iPhone5,1"]) {
        modelName = @"iPhone 5";
    }
    else if([modelName isEqualToString:@"iPhone5,2"]) {
        modelName = @"iPhone 5";
    }
    else if([modelName isEqualToString:@"iPhone5,3"]) {
        modelName = @"iPhone 5C";
    }
    else if([modelName isEqualToString:@"iPhone5,4"]) {
        modelName = @"iPhone 5C";
    }
    else if([modelName isEqualToString:@"iPhone6,1"]) {
        modelName = @"iPhone 5S";
    }
    else if([modelName isEqualToString:@"iPhone6,2"]) {
        modelName = @"iPhone 5S";
    }
    else if([modelName isEqualToString:@"iPhone7,1"]) {
        modelName = @"iPhone 6";
    }
    else if([modelName isEqualToString:@"iPhone7,2"]) {
        modelName = @"iPhone 6S";
    }
    else if([modelName isEqualToString:@"iPod1,1"]) {
        modelName = @"iPod 1st Gen";
    }
    else if([modelName isEqualToString:@"iPod2,1"]) {
        modelName = @"iPod 2nd Gen";
    }
    else if([modelName isEqualToString:@"iPod3,1"]) {
        modelName = @"iPod 3rd Gen";
    }
    else if([modelName isEqualToString:@"iPod4,1"]) {
        modelName = @"iPod 4th Gen";
    }
    else if([modelName isEqualToString:@"iPod5,1"]) {
        modelName = @"iPod 5th Gen";
    }
    else if([modelName isEqualToString:@"iPad1,1"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,1"]) {
        modelName = @"iPad 2(WiFi)";
    }
    else if([modelName isEqualToString:@"iPad2,2"]) {
        modelName = @"iPad 2(GSM)";
    }
    else if([modelName isEqualToString:@"iPad2,3"]) {
        modelName = @"iPad 2(CDMA)";
    }
    else if([modelName isEqualToString:@"iPad2,4"]) {
        modelName = @"iPad 2(WiFi + New Chip)";
    }
    else if([modelName isEqualToString:@"iPad2,5"]) {
        modelName = @"iPad mini (WiFi)";
    }
    else if([modelName isEqualToString:@"iPad2,6"]) {
        modelName = @"iPad mini (GSM)";
    }
    else if([modelName isEqualToString:@"iPad3,1"]) {
        modelName = @"iPad 3(WiFi)";
    }
    else if([modelName isEqualToString:@"iPad3,2"]) {
        modelName = @"iPad 3(GSM)";
    }
    else if([modelName isEqualToString:@"iPad3,3"]) {
        modelName = @"iPad 3(CDMA)";
    }
    
    return modelName;
}

- (IBAction)feedbackAction:(id)sender {
    [self.view endEditing:YES];
    //先判断输入是否为空
    if ([self.textView.text isEqualToString:@""]) {
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"请先输入您的宝贵建议和反馈"];
        return;
    }
    NSString *url = GETAPIURL(@"api/Suggestion/Upload");
    NSDictionary *postForm = @{@"mobile":[[NSUserDefaults standardUserDefaults] objectForKey:@"Mobile"],
                               @"system":[NSString stringWithFormat:@"%@%@%@",[[self class] deviceModelName],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]],
                               @"text":self.textView.text
                               };
    SWTProgressHUD *hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"发送中.."];

    [[RequestInstance shareInstance] POST:url parameters:postForm usableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:dic[@"data"][@"message"]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        alert.tag = 13;
        [alert show];
    } unusableStatus:^(NSDictionary *dic) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:dic[@"message"]];
    } error:^(NSError *error) {
        [hud hideAnimated:YES];
        [SWTProgressHUD toastMessageAddedTo:self.view message:@"网络错误"];

    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 13) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end

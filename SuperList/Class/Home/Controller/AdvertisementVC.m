//
//  AdvertisementVC.m
//  SDL
//
//  Created by 胡定锋Mac on 2017/2/10.
//  Copyright © 2017年 胡定锋. All rights reserved.
//

#import "AdvertisementVC.h"
#import "UIColor+StringToColor.h"
#import "UIImageView+WebCache.h"

@interface AdvertisementVC ()

@end

@implementation AdvertisementVC

- (NSString *)imagePath
{
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [pathcaches objectAtIndex:0];
    return [cacheDirectory stringByAppendingString:@"advertisement.png"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self imagePath]];
    
    [self.iamgeview setImage:image];
    
    [self.iamgeview setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(wentanyWhere)];
    [self.iamgeview addGestureRecognizer:tap];
    
    // 设置引导页上的跳过按钮
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setFrame:CGRectMake(kScreenWidth*0.8, 20, 50, 25)];
    [skipButton setTitle:@"跳过5s" forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [skipButton setTitleColor:[UIColor hexStringToColor:@"#FFFFFF"] forState:UIControlStateNormal];
    [skipButton setBackgroundColor:[UIColor clearColor]];
    [skipButton.layer setCornerRadius:3.0];
    skipButton.layer.borderWidth = 0.5f;
    skipButton.layer.borderColor = [UIColor hexStringToColor:@"#FFFFFF"].CGColor;
    [skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    __block int timeout = 5;
    
    if (self.dict[@"Seconds"]) {
        timeout=[self.dict[@"Seconds"] intValue]; //倒计时时间
        [skipButton setTitle:[NSString stringWithFormat:@"跳过%ds",timeout] forState:UIControlStateNormal];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [skipButton setTitle:@"跳过" forState:UIControlStateNormal];
                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }else{
            NSString *strTime = [NSString stringWithFormat:@"跳过%ds", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [skipButton setTitle:strTime forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);

}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)buttonClick:(id)sender{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)wentanyWhere{
    
//    [self dismissViewControllerAnimated:NO completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(wentanywhere:data:)]) {
        [self.delegate wentanywhere:self data:self.dict];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

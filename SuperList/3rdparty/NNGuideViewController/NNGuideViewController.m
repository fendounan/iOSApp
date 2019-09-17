//
//  NNGuideViewController.m
//  NCENew
//
//  Created by palxex on 15/3/18.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "NNGuideViewController.h"
#import "SwitchSlideView.h"
#import "BaseTabBarController.h"
static BOOL splashShown;

@interface NNGuideViewController ()<SwitchSlideViewProtocol> {
    NSArray *images;
}
@property (nonatomic,retain) SwitchSlideView *switchSlide;

@end

@implementation NNGuideViewController

+ (instancetype)Instance {
    NSString *localVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *splashShownVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SplashShownVersion"];
    if (splashShownVersion) {
        if ([localVersion isEqualToString:splashShownVersion]) {
            return nil;
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:localVersion forKey:@"SplashShownVersion"];
            id vc = [[self alloc]init];
            return vc;
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:localVersion forKey:@"SplashShownVersion"];
        id vc = [[self alloc]init];
        return vc;
    }
    /*
    [self loadSettings];
    if( splashShown ) {
        return nil;
    }else {
        id vc = [[self alloc]init];
        return vc;
    }
     */
}

+ (void)setSplashShown:(BOOL)_splashShown {
    splashShown = _splashShown;
    NSString *filename=[self getAppSettingFileName];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filename contents:nil attributes:nil];
    [@{@"splash_shown":@(splashShown)} writeToFile:filename atomically:YES];
}

+ (void)loadSettings {
    NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:[self getAppSettingFileName]];
    if( settings != nil ) {
        [self setSplashShown:[settings[@"splash_shown"] boolValue]];
    }
}

+ (NSString *)getAppSettingFileName {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"settings.json"];
    return filePath;
}

- (void)setImages:(NSArray*)array {
    images = array;
}
- (BOOL)show:(UIViewController*)vc {
    [vc presentViewController:self animated:YES completion:nil];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switchSlide = [[SwitchSlideView alloc] initWithFrame:self.view.frame];
    self.switchSlide.delegate = self;
    self.switchSlide.noTimer = YES;
    self.switchSlide.noBtn = NO;
    [self.switchSlide setImagesWithArray:images];
    [self.view addSubview:self.switchSlide];
}

- (void)tapOn:(NSInteger)index {
    if( index == images.count - 1 ) {
        [[self class] setSplashShown:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (_finishedBlock) {
            _finishedBlock();
        } 
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

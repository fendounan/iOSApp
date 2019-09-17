//
//  SWTWebViewController.m
//  SuperList
//
//  Created by SWT on 2017/11/14.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "SWTWebViewController.h"
#import "Masonry.h"
#import "BaseViewController.h"
#import "UIColor+StringToColor.h"
#import "SWTProgressHUD.h"
#import "MD5Util.h"
#import "BaseNavigationController.h"
#import "SWTUtils.h"
#import <WebKit/WebKit.h>
#import "MD5Util.h"
#import "TimeTool.h"

@interface SWTWebViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) SWTProgressHUD *hud;

@end

@implementation SWTWebViewController{
    BOOL _isFirstLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    
    if (!_titleString) {
        _titleString = [self theTitleString];
    }
    
    self.navigationItem.title = _titleString;
    
    [self setNavigationBar];
    
    _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中..."];
    
    if (_htmlString && _htmlString.length) {
        [self.webView loadHTMLString:_htmlString baseURL:nil];
    } else {
        if (!_urlString) {
            _urlString = [self theUrlString];
        }
        if (_urlString && _urlString.length) {
            
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)setNavigationBar{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 67, 44)];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 0, 30, 44);
    [backButton setImage:[UIImage imageNamed:@"navigation_back_white"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(CGRectGetMaxX(backButton.frame), backButton.frame.origin.y, 22, 44);
    [deleteBtn setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateNormal
     ];
    [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:deleteBtn];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    } else {
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -15;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
        self.navigationItem.leftBarButtonItems = @[spaceItem,backItem];
    }
}

- (void)backAction:(UIButton *)sender{
    if (_webView.canGoBack) {
        [_webView goBack];
        [_webView reload];
    } else {
        if (_isPresent) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)deleteAction:(UIButton *)sender{
    if (_isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_isFirstLoad) {
        [self.webView reload];
    } else {
        _isFirstLoad = YES;
    }
}

#pragma mark - private

- (void)setUpView{
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view); 
    }];
}


-(NSString *)toJSON:(NSDictionary *)dict{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}


#pragma mark - lazy load

- (WKWebView *)webView{
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _webView;
}

#pragma KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.webView.estimatedProgress == 0||self.webView.estimatedProgress < 1 ) {
            if (!_hud) {
                _hud = [SWTProgressHUD showHUDAddedTo:self.view text:@"加载中..."];
            }
        } else if (self.webView.estimatedProgress >= 1) {
            if (_hud) {
                [_hud hideAnimated:YES];
                _hud  = nil;
            }
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        
        self.navigationItem.title = _webView.title;
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    UIApplication *app = [UIApplication sharedApplication];
    // 打电话
    if ([scheme isEqualToString:@"tel"]) {
        if ([app canOpenURL:URL]) {
            NSString *resourceSpecifier = [URL resourceSpecifier];  
            NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];  
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
            // 一定要加上这句,否则会打开新页面
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } 
    }
    // 打开appstore
    if ([URL.absoluteString containsString:@"ituns.apple.com"]) {
        if ([app canOpenURL:URL]) {
            [app openURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

-(void)reloadView{
    
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)dealloc{
    
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(NSString*)theTitleString{
    
    return nil;
}

-(NSString*)theUrlString{
    
    return nil;
}

@end

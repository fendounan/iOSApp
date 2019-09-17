//
//  UITableView+MJRefresh.m
//  SuperList
//
//  Created by apple on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "UITableView+MJRefresh.h"
#import "NSObject+X.h"
#import "RequestInstance.h"
#import "SYBLocalDefine.h"
#import "Masonry.h"
#import "UIColor+StringToColor.h"
#import "SWTProgressHUD.h"

@implementation UITableView (MJRefresh)
ADD_DYNAMIC_INT_PROPERTY(currentPage,setCurrentPage);
ADD_DYNAMIC_INT_PROPERTY(totoalPage,setTotoalPage);

-(void)registMJheaderRefresh:(BOOL)headerIsRefresh footerRefresh:(BOOL)footerIsRefresh selector:(SEL)selector control:(id)conrol;{
   
    __weak typeof(self) weakSelf = self;
   
    weakSelf.currentPage = 1;
    weakSelf.totoalPage = 1;
    weakSelf.mj_footer.automaticallyHidden = YES;
    MJRefreshNormalHeader *header;
    MJRefreshAutoNormalFooter *footer;
    if (headerIsRefresh == YES) {
        
        header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
            weakSelf.currentPage = 1;
            [conrol performSelector:selector withObject:nil];
        }];
        
    }
    
    if (footerIsRefresh == YES) {
        
        footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
            weakSelf.currentPage ++;
            [conrol performSelector:selector withObject:nil];
        }];
    }
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    weakSelf.mj_header = header;
    weakSelf.mj_footer = footer;
}

-(void)refreshAPi:(NSString *)api parameter:(id)param resultArray:(NSMutableArray*)resultArray{
    
    __weak typeof(self) weakSelf = self;
    [weakSelf refreshAPi:api parameter:param resultArray:resultArray resultBlock:nil];
}

- (void)refreshAPi:(NSString *)api parameter:(id)param resultArray:(NSMutableArray*)resultArray resultBlock:(void(^)(id))resultBlock
{
    __weak typeof(self) weakSelf = self;
    
    NSAssert(resultArray != nil, @"resultArray cannot be nil!");
    
    NSMutableDictionary *postForm;
    if (param) {
        postForm = [param mutableCopy];
    } else {
        postForm = [NSMutableDictionary dictionary];
    }
    
    postForm[@"page"] = [NSString stringWithFormat:@"%d",weakSelf.currentPage];
    
    [[RequestInstance shareInstance] POST:GETAPIURL(api) parameters:postForm usableStatus:^(NSDictionary *dic) {
        
        weakSelf.currentPage = [postForm[@"page"] intValue];
        if(weakSelf.currentPage == 1) {
            [resultArray removeAllObjects];
        }
        NSArray *listArr = dic[@"data"];
        
        for (NSDictionary *tempDic in listArr) {
            
            [resultArray addObject:tempDic];
        }
        
        if( resultBlock ) {
            
            resultBlock(dic);
            [weakSelf reloadData];
        }else{
            [weakSelf reloadData];
        }
        [weakSelf.mj_header endRefreshing];
        
        if (listArr.count) {
        
            [weakSelf.mj_footer endRefreshing];
        } else {
            
            if (weakSelf.currentPage == 1) {
                
                [weakSelf.mj_footer endRefreshing];
            }else{
                [weakSelf.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } unusableStatus:^(NSDictionary *dic) {
        
        [weakSelf.mj_header endRefreshing];
        [weakSelf.mj_footer endRefreshing];
        [SWTProgressHUD toastMessageAddedTo:weakSelf message:dic[@"message"]];
    } error:^(NSError *error) {
        
        [weakSelf.mj_header endRefreshing];
        [weakSelf.mj_footer endRefreshing];
        [SWTProgressHUD toastMessageAddedTo:weakSelf message:@"网络数据获取失败"];
    }];
}

@end

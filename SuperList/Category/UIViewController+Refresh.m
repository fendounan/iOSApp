//
//  UIViewController+Refresh.m
//  SuperList
//
//  Created by hdf on 16/8/29.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import "UIViewController+Refresh.h"
#import "NSObject+X.h"
#import "RequestInstance.h"
#import "SYBLocalDefine.h"
#import "Masonry.h"
#import "UIColor+StringToColor.h"
#import "SWTProgressHUD.h"

@implementation UIViewController (Refresh)
ADD_DYNAMIC_PROPERTY(UITableView *, dfTableView, setDfTableView);
ADD_DYNAMIC_INT_PROPERTY(currentPage,setCurrentPage);
ADD_DYNAMIC_INT_PROPERTY(totoalPage,setTotoalPage);
ADD_DYNAMIC_SEL_PROPERTY(selecter, setSelecter);
ADD_DYNAMIC_INT_PROPERTY(footerFlag, setFooterFlag);


-(void)setupRefresh:(UITableView *)tableView hasHeaderRefresh:(BOOL)HeaderFlag hasFooterRefresh:(BOOL)footerFlag withPage:(NSInteger)page ForSelector:(SEL)selector{
    
    __weak UIViewController *weakSelf = self;
    
    weakSelf.footerFlag = 0;
    weakSelf.selecter = selector;

    //初始化设置MJ刷新
    weakSelf.dfTableView = tableView;
    weakSelf.currentPage = 0;
    weakSelf.dfTableView.mj_footer.automaticallyHidden = YES;
    MJRefreshNormalHeader *header;
    MJRefreshAutoNormalFooter *footer;
    if (HeaderFlag == YES) {
        
         header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
            weakSelf.currentPage = 0;
            [weakSelf performSelector:selector withObject:nil];
        }];
        
    }
    
    if (footerFlag == YES) {
        weakSelf.footerFlag = 1;
        
        footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个block
//            weakSelf.currentPage ++;
            [weakSelf performSelector:selector withObject:nil];
            
        }];
    }
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    tableView.mj_header = header;
    tableView.mj_footer = footer;

}

- (void)updateFuncTemplate:(UIView *)emptyView api:(NSString*)api postMixin:(NSDictionary*)postMixin resultArray:(NSMutableArray*)resultArray{
    __weak UIViewController *weakSelf = self;
    [weakSelf updateFuncTemplate:emptyView api:api postMixin:postMixin resultArray:resultArray resultBlock:nil];
}

- (void)updateFuncTemplate:(UIView *)emptyView api:(NSString*)api postMixin:(NSDictionary*)postMixin resultArray:(NSMutableArray*)resultArray resultBlock:(void(^)(id))resultBlock{
    NSAssert(resultArray != nil, @"resultArray cannot be nil!");
    
    __weak UIViewController *weakSelf = self;
    
    NSMutableDictionary *postForm;
    if (postMixin) {
        postForm = [postMixin mutableCopy]; 
    } else {
        postForm = [NSMutableDictionary dictionary];
    }
    if(![[postForm objectForKey:@"p"] isEqual:[NSNull null]]){
       
    }else
    {
        postForm[@"p"] = [NSString stringWithFormat:@"%d",weakSelf.currentPage];
    }

    
        
    [[RequestInstance shareInstance] POST:GETAPIURL(api) parameters:postForm usableStatus:^(NSDictionary *dic) {
        
        NSArray *listArr = dic[@"data"];

        if(weakSelf.currentPage == 0) {
            [resultArray removeAllObjects];
        }
        
        if( resultBlock) {
            resultBlock(dic);
            [weakSelf.dfTableView reloadData];
        } else {
            for (NSDictionary *tempDic in listArr) {
                [resultArray addObject:tempDic];
            }
        }
        
        [weakSelf.dfTableView.mj_header endRefreshing];
        
        if (listArr.count) {
            
            if (weakSelf.footerFlag == 1) {
                if (weakSelf.currentPage == 0) {
                    if (!weakSelf.dfTableView.mj_footer) {
                        // 添加mj_footer
                        MJRefreshAutoNormalFooter *footer;
                        footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                            // 进入刷新状态后会自动调用这个block
                            [weakSelf performSelector:weakSelf.selecter withObject:nil];
                        }];
                        [footer setTitle:@"加载完成" forState:MJRefreshStateIdle];
                        [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
                        weakSelf.dfTableView.mj_footer = footer;
                    }
                }
            }
            [weakSelf.dfTableView reloadData];
            [weakSelf.dfTableView.mj_footer endRefreshing]; 
            
            weakSelf.currentPage ++;
            
        } else {
            if (weakSelf.currentPage == 0) {
                
                if (weakSelf.footerFlag == 1) {
                    
                    weakSelf.dfTableView.mj_footer = nil;
                }
            } else {
                [weakSelf.dfTableView.mj_footer endRefreshingWithNoMoreData]; 
            }
        }
        
    } unusableStatus:^(NSDictionary *dic) {
        [SWTProgressHUD toastMessageAddedTo:weakSelf.dfTableView message:dic[@"message"]];
        [weakSelf.dfTableView.mj_header endRefreshing];
        [weakSelf.dfTableView.mj_footer endRefreshing];
        
    } error:^(NSError *error) {
        
        [weakSelf.dfTableView.mj_header endRefreshing];
        [weakSelf.dfTableView.mj_footer endRefreshing]; 
        [SWTProgressHUD toastMessageAddedTo:weakSelf.dfTableView message:@"网络错误"];
    }];
}

@end

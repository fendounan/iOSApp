//
//  UIViewController+Refresh.h
//  SuperList
//
//  Created by hdf on 16/8/29.
//  Copyright © 2016年 sanweitong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>
@interface UIViewController (Refresh)
@property (nonatomic,assign)int currentPage;
@property (nonatomic,assign)int totoalPage;
@property (nonatomic,weak)UITableView *dfTableView;
@property (nonatomic, assign) SEL selecter;
@property (nonatomic, assign) int footerFlag;

-(void)setupRefresh:(UITableView *)tableView hasHeaderRefresh:(BOOL)HeaderFlag hasFooterRefresh:(BOOL)footerFlag withPage:(NSInteger)page ForSelector:(SEL)selector;

- (void)updateFuncTemplate:(UIView *)emptyView api:(NSString*)api postMixin:(NSDictionary*)postMixin resultArray:(NSMutableArray*)resultArray;
- (void)updateFuncTemplate:(UIView *)emptyView api:(NSString*)api postMixin:(NSDictionary*)postMixin resultArray:(NSMutableArray*)resultArray resultBlock:(void(^)(id))resultBlock;
@end

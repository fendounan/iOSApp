//
//  UITableView+MJRefresh.h
//  SuperList
//
//  Created by apple on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>

@interface UITableView (MJRefresh)
@property (nonatomic,assign)int currentPage;
@property (nonatomic,assign)int totoalPage;

-(void)registMJheaderRefresh:(BOOL)headerIsRefresh footerRefresh:(BOOL)footerIsRefresh selector:(SEL)selector control:(id)conrol;
-(void)refreshAPi:(NSString *)api parameter:(id)param resultArray:(NSMutableArray*)resultArray;

- (void)refreshAPi:(NSString *)api parameter:(id)param resultArray:(NSMutableArray*)resultArray resultBlock:(void(^)(id))resultBlock;

@end

//
//  SYBVersionAlertView.m
//  SuperList
//
//  Created by SWT on 2018/1/15.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "SYBVersionAlertView.h"
#import "Masonry.h"
#import "UIColor+StringToColor.h"
#import "SYBVersionAlertCell.h"
#import "NSString+Size.h"

@interface SYBVersionAlertView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString * const SYBVersionAlertCellID = @"SYBVersionAlertCellID";

@implementation SYBVersionAlertView

- (instancetype)initWithContent:(NSArray *)contentArr delegate:(id)delegate forceUpdating:(BOOL)isForceUpdating{
    self = [super init];
    if (self) {
        
        _contentArr = [contentArr copy];
        _isForceUpdating = isForceUpdating;
        if (delegate) {
            _delegate = delegate;
        }
        
        [self setUpView];
    }
    
    return self;
}

- (void)setUpView{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self addSubview:maskView];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"有新版本发布";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor hexStringToColor:@"#333333"];
    titleLab.font = [UIFont systemFontOfSize:18 weight:0.5];
    [contentView addSubview:titleLab];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerNib:[UINib nibWithNibName:@"SYBVersionAlertCell" bundle:nil] forCellReuseIdentifier:SYBVersionAlertCellID];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.estimatedRowHeight = 44;
    tableView.rowHeight = UITableViewAutomaticDimension;
    [contentView addSubview:tableView];
    
    UIView *seperatorView = [[UIView alloc] init];
    seperatorView.backgroundColor = [UIColor hexStringToColor:@"#e1e1e1"];
    [contentView addSubview:seperatorView];
    
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBtn setTitle:@"立即升级" forState:UIControlStateNormal];
    updateBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:0.3];
    [updateBtn setTitleColor:[UIColor hexStringToColor:mColor_TopTarBg] forState:UIControlStateNormal];
    [updateBtn addTarget:self action:@selector(versionUpdateAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:updateBtn];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self); 
    }];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(contentView.mas_top).offset(30);
        make.height.mas_equalTo(20);
    }];
    
    CGFloat tableViewH = [self tableViewHeight];
    if (tableViewH > [UIScreen mainScreen].bounds.size.height / 3) {
        tableViewH = [UIScreen mainScreen].bounds.size.height / 3;
        tableView.scrollEnabled = YES;
        tableView.showsVerticalScrollIndicator = YES;
    }
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(titleLab.mas_bottom).offset(23);
        make.height.mas_equalTo(tableViewH);
    }];
    
    [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(tableView.mas_bottom).offset(28);
        make.height.mas_equalTo(1);
    }];
    
    [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(seperatorView.mas_bottom);
        make.height.mas_equalTo(45);
    }];
    
    if (_isForceUpdating) { // 强制更新
        
        CGFloat contentViewH = 25 + tableViewH + 1 + 45 + 30 + 23 + 28;
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(40);
            make.right.equalTo(self.mas_right).offset(-40);
            make.height.mas_equalTo(contentViewH);
            make.centerY.equalTo(maskView.mas_centerY);
        }];
        
    } else { // 非强制更新
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.backgroundColor = [UIColor clearColor];
        [deleteBtn setImage:[UIImage imageNamed:@"common_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        
        CGFloat contentViewH = 25 + tableViewH + 1 + 45 + 30 + 23 + 28;
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(40);
            make.right.equalTo(self.mas_right).offset(-40);
            make.height.mas_equalTo(contentViewH);
            make.centerY.equalTo(maskView.mas_centerY).offset(-37.5);
        }];
        
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView.mas_bottom).offset(40);
            make.centerX.equalTo(maskView.mas_centerX);
            make.width.height.mas_equalTo(35);
        }];
    }
    
    

}

- (void)show{
    self.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)hide{
    [self removeFromSuperview];
}

- (CGFloat)tableViewHeight{
    
    CGFloat totalH = 0;
    for (int i = 0; i < _contentArr.count; i++) {
        NSString *indexString = [NSString stringWithFormat:@"%d.",i+1];
        CGFloat indexW = [indexString widthWithFont:[UIFont systemFontOfSize:15]];
        CGFloat stringW = [UIScreen mainScreen].bounds.size.width - 80 - 40 - indexW - 2;
        NSString *contentString = _contentArr[i];
        totalH = totalH + [contentString heightWithString:contentString width:stringW font:[UIFont systemFontOfSize:15]].height + 5;
        
    }
    return totalH;
}

#pragma mark - action

- (void)versionUpdateAction:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(versionUpdate:)]) {
        [_delegate versionUpdate:self];
    }
}

- (void)deleteAction:(UIButton *)sender{
    [self hide];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SYBVersionAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:SYBVersionAlertCellID forIndexPath:indexPath];
//    cell.indexLab.text = [NSString stringWithFormat:@"%ld.",indexPath.row + 1];
    //暂时去掉序号
    cell.indexLab.text = @"";
    cell.contentLab.text = _contentArr[indexPath.row];
    
    return cell;
}

@end

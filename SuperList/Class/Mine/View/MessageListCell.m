//
//  MessageListCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/14.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "MessageListCell.h"
#import "MessageListModel.h"
#import "UIColor+StringToColor.h"

@interface MessageListCell()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labMubiao;
@property (weak, nonatomic) IBOutlet UILabel *labTime;

@end


@implementation MessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.bgView.clipsToBounds = YES;
    [self.bgView.layer setCornerRadius:5];
//    self.bgView.layer.shouldRasterize = YES;
    self.bgView.layer.borderColor = [UIColor hexStringToColor:@"#e2e2e2"].CGColor;
    self.bgView.layer.borderWidth = 0.5;
    
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellmodel:(MessageListModel *)cellmodel
{
    self.labTitle.text = [NSString stringWithFormat:@"%@,如有需要请联系%@",cellmodel.Text,cellmodel.Mobile];
    NSArray *array = [cellmodel.TargetMobile componentsSeparatedByString:@","];
    self.labMubiao.text = [NSString stringWithFormat:@"目标：%lu个",array.count];
    self.labTime.text = cellmodel.AddTime;
}

@end

//
//  ScheduleListCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/12.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ScheduleListCell.h"
#import "MyTaskModel.h"

@interface ScheduleListCell()

@property (weak, nonatomic) IBOutlet UISwitch *switchShow;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelect;

@property (weak, nonatomic) IBOutlet UILabel *latTitle;

@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ivSelectWidth;

@end

@implementation ScheduleListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellmodel:(MyTaskModel *)cellmodel
{
    
    
    
    if ([cellmodel.isSelect intValue] == 1) {
        [self.ivSelect setHighlighted:YES];
    }else
    {
        [self.ivSelect setHighlighted:NO];
    }
    
    if (self.isDelete) {
        self.ivSelect.hidden = NO;
        self.ivSelectWidth.constant = 20.0f;
    }else
    {
        self.ivSelect.hidden = YES;
        self.ivSelectWidth.constant = 0.0f;
    }
    
    self.latTitle.text = cellmodel.TaskText;
    self.labTime.text = cellmodel.CreateTime;
    
    if ([cellmodel.IsClock intValue] == 1) {
        self.switchShow.on = YES;
    }else
    {
        self.switchShow.on = NO;
    }
}

@end

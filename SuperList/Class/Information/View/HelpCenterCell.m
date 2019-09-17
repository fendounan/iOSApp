//
//  HelpCenterCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "HelpCenterCell.h"
#import "UIColor+StringToColor.h"
#import "HelpCenterModel.h"

@interface HelpCenterCell()
@property (weak, nonatomic) IBOutlet UIView *contentview;

@property (weak, nonatomic) IBOutlet UIView *topBgView;

@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@end

@implementation HelpCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentview.clipsToBounds = YES;
    [self.contentview.layer setCornerRadius:5];
//    self.contentview.layer.shouldRasterize = YES;
    self.contentview.layer.borderColor = [UIColor hexStringToColor:@"#e2e2e2"].CGColor;
    self.contentview.layer.borderWidth = 0.5;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.topBgView.backgroundColor = [UIColor hexStringToColor:@"#e2e2e2"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellmodel:(HelpCenterModel *)cellmodel
{
    self.labTitle.text = cellmodel.Title;
    self.labContent.text = cellmodel.Content;
}

@end

//
//  InformationListCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/11.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "InformationListCell.h"
#import "UIColor+StringToColor.h"
#import "InformationListModel.h"
#import "UIImageView+WebCache.h"

@interface InformationListCell()
@property (weak, nonatomic) IBOutlet UIImageView *icoView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UIImageView *isNewImageView;
@property (weak, nonatomic) IBOutlet UIView *myContentView;

@end

@implementation InformationListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.myContentView.clipsToBounds = YES;
    [self.myContentView.layer setCornerRadius:5];
    //    self.myContentView.layer.shouldRasterize = YES;
    self.myContentView.layer.borderColor = [UIColor hexStringToColor:@"#e2e2e2"].CGColor;
    self.myContentView.layer.borderWidth = 0.5;
    
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellmodel:(InformationListModel *)model
{
    self.labTitle.text = model.title;
    self.labTime.text = model.CreateTime;
    [self.icoView sd_setImageWithURL:[NSURL URLWithString:model.img_url] placeholderImage:[UIImage imageNamed:@"loader_60"]];
    
    if ([model.IsNew intValue] == 1) {
        self.isNewImageView.hidden = NO;
    }else
    {
        self.isNewImageView.hidden = YES;
    }
}

@end

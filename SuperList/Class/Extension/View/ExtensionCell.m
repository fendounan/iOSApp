//
//  ExtensionCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/9.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ExtensionCell.h"
#import "ExtensionModel.h"
#import "UIImageView+WebCache.h"

@interface ExtensionCell()

@property (weak, nonatomic) IBOutlet UIImageView *hotImageView;

@end


@implementation ExtensionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.hotImageView.clipsToBounds = YES;
    [self.hotImageView.layer setCornerRadius:10];
//    self.hotImageView.layer.shouldRasterize = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(ExtensionModel *)model{
    _model = model;
    
    [self.hotImageView sd_setImageWithURL:[NSURL URLWithString:model.Ico] placeholderImage:[UIImage imageNamed:@"loader_300_720"]];
    
}
@end

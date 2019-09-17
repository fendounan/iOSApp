//
//  InformationCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/10.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "InformationCell.h"
#import "InformationCategorysModel.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"


@interface InformationCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIImageView *isNewImageView;

@end

@implementation InformationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.isNewImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setCellmodel:(InformationCategorysModel *)cellmodel
{
    self.labName.text = cellmodel.CategoryName;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:cellmodel.Ico] placeholderImage:[UIImage imageNamed:@"loader_60"]];
    
    if ([cellmodel.IsNew intValue] == 1) {
        self.isNewImageView.hidden = NO;
    }else
    {
        self.isNewImageView.hidden = YES;
    }
}

@end

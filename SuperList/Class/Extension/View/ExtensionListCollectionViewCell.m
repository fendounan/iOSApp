//
//  ExtensionListCollectionViewCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/9.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "ExtensionListCollectionViewCell.h"
#import "ExtensionListModel.h"
#import "UIColor+StringToColor.h"
#import "UIImageView+WebCache.h"

@interface ExtensionListCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *tel;

@end

@implementation ExtensionListCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageView.clipsToBounds = YES;
    [self.imageView.layer setCornerRadius:5];
    self.imageView.layer.shouldRasterize = YES;
    
    self.clipsToBounds = YES;
    [self.layer setCornerRadius:5];
//    self.layer.shouldRasterize = YES;
    self.layer.borderColor = [UIColor hexStringToColor:@"#e2e2e2"].CGColor;
    self.layer.borderWidth = 0.5;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setCellmodel:(ExtensionListModel *)cellmodel
{
    _cellmodel = cellmodel;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:cellmodel.Picture] placeholderImage:[UIImage imageNamed:@"loader_400"]];
    self.title.text = cellmodel.title;
    self.tel.text = cellmodel.mobile;
}

@end

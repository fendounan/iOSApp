//
//  HomePageCell.m
//  SuperList
//
//  Created by XuYan on 2018/7/5.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "HomePageCell.h"
#import "UIColor+StringToColor.h"
#import "HomeQueryModel.h"
#import "Masonry.h"

@interface HomePageCell ()

@property (weak, nonatomic) IBOutlet UILabel *labTel;
@property (weak, nonatomic) IBOutlet UIImageView *ivTel;

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTitleName;
@property (weak, nonatomic) IBOutlet UILabel *labYuan;
@property (weak, nonatomic) IBOutlet UILabel *labFromYuan;
@property (weak, nonatomic) IBOutlet UIImageView *ivNew;

@end

@implementation HomePageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.labYuan.layer.borderColor = [UIColor hexStringToColor:@"#ffb400"].CGColor;
    self.labYuan.layer.borderWidth = 0.5;
    self.labYuan.hidden = YES;
    self.labTel.hidden = YES;
    self.ivTel.hidden = YES;
    self.labFromYuan.hidden = YES;
    self.ivNew.hidden = YES;
    
    self.labTitleName.lineBreakMode = NSLineBreakByTruncatingTail;
    self.labTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(HomeQueryModel *)model
{
    if ([model.IsNew isEqualToString:@"1"]) {
        self.ivNew.hidden = NO;
    }else
    {
        self.ivNew.hidden = YES;
    }
    
    if (model.tel) {
        self.ivTel.hidden = NO;
        self.labTel.hidden = NO;
        self.labTel.text = model.tel;
    }else{
        self.labTel.hidden = YES;
        self.ivTel.hidden = YES;
    }
    
    self.labYuan.text = @" 源 ";
    
    self.labTitleName.text = model.compname;
    self.labTitle.text = model.compname;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ShowOrigin"]&&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowOrigin"] isEqualToString:@"1"]) {
        self.labYuan.hidden = NO;
        self.labFromYuan.hidden = NO;
        self.labTitle.hidden = NO;
        self.labTitleName.hidden = YES;
        self.labFromYuan.text = model.fromtype;
    }else
    {
        self.labYuan.hidden = YES;
        self.labFromYuan.hidden = YES;
        self.labTitle.hidden = YES;
        self.labTitleName.hidden = NO;
    }
}

@end

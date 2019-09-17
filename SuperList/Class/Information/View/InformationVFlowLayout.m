//
//  InformationVFlowLayout.m
//  SuperList
//
//  Created by XuYan on 2018/7/10.
//  Copyright © 2018年 SWT. All rights reserved.
//

#import "InformationVFlowLayout.h"

@interface InformationVFlowLayout()

@end

@implementation InformationVFlowLayout
-(id)init
{
    if (!(self = [super init])) return nil;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    
    //    CGFloat cellSpace = 5.0;
    //    CGFloat cellWidth = (size.width - cellSpace * (4 + 1)) / 4;//总宽－5个间隔（4个cell）
    CGFloat cellSpace = 0.0;
    CGFloat cellVSpace = 1.0;
    CGFloat cellWidth = size.width / 4.0;
    
    self.itemSize = CGSizeMake(cellWidth, 100);//Item size(每个item的大小)
    self.sectionInset = UIEdgeInsetsMake(cellSpace, cellSpace, cellSpace, cellSpace);//某个section中cell的边界范围。
    self.headerReferenceSize = CGSizeMake(size.width, 50);//每个section的Header宽高
    self.footerReferenceSize = CGSizeMake(size.width, 5);//每个section的Footer宽高
    
    self.minimumInteritemSpacing = cellSpace;//Inter cell spacing（每行内部cell item的间距）
    self.minimumLineSpacing = cellVSpace;//Line spacing（每行的间距）
    
    return self;
}
@end

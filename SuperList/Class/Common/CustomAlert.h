//
//  CustomAlert.h
//  NCENew
//
//  Created by hdf on 16/6/20.
//  Copyright © 2016年 cn.edu.ustc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomAlertDelegate<NSObject>
- (void)alertClick;
@end

@interface CustomAlert : UIView
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertContent;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, readwrite, nonatomic) id <CustomAlertDelegate>delegate;
@end

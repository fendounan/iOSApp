//
//  AdvertisementVC.h
//  SDL
//
//  Created by 胡定锋Mac on 2017/2/10.
//  Copyright © 2017年 胡定锋. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AdvertisementVCDelegate <NSObject>

-(void)wentanywhere:(UIViewController*)contrl data:(NSDictionary *)dic;
@end
@interface AdvertisementVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *iamgeview;
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)NSString *imagePath;
@property (nonatomic,assign)id delegate;
@end

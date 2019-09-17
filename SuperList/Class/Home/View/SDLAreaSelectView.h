//
//  SDLAreaSelectView.h
//  SDL
//
//  Created by 胡定锋Mac on 2016/12/9.
//  Copyright © 2016年 胡定锋. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SDLAreaSelectViewDelegate<NSObject>

-(void)finishedSelecteWith:(NSString *)areaShowValue areaData:(NSDictionary *)areaDict;

-(void)selectviewDismissed;
@end
@interface SDLAreaSelectView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign)id<SDLAreaSelectViewDelegate>delegate;

- (void)setAddressList:(NSArray *)addressList;

- (void)setName:(NSString *)p cityName:(NSString *)c;
@end

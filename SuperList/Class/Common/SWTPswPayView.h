//
//  SWTPswPayView.h
//  SuperList
//
//  Created by SWT on 2017/11/28.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTPswPayView;

@protocol SWTPswPayViewDelegate <NSObject>

@optional
- (void)inputCompleted:(SWTPswPayView *)payView password:(NSString *)password;

@end

@interface SWTPswPayView : UIView

@property (nonatomic, strong, readonly) NSString *price;
@property (nonatomic, strong, readonly) NSString *heading;
@property (nonatomic, weak) id<SWTPswPayViewDelegate> delegate;

+ (instancetype)payViewWithPrice:(NSString *)price headingString:(NSString *)heading delegate:(id)delegate;
- (instancetype)initWithPrice:(NSString *)price headingString:(NSString *)heading delegate:(id)delegate;

- (void)show;
- (void)hideAnimated:(BOOL)animated;

@end

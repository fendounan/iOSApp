//
//  SWTCommentBox.h
//  SuperList
//
//  Created by SWT on 2017/12/21.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SWTCommentBoxDelegate <NSObject>

@optional
- (void)commentBoxSendMessage:(NSString *)message;

@end

@interface SWTCommentBox : UIView

@property (nonatomic, weak) id<SWTCommentBoxDelegate> delegate;

// 清除评论信息
- (void)cleanUpMessage;

@end

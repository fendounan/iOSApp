//
//  SWTWebViewController.h
//  SuperList
//
//  Created by SWT on 2017/11/14.
//  Copyright © 2017年 SWT. All rights reserved.
//

#import "BaseViewController.h"

@interface SWTWebViewController : BaseViewController

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *htmlString;

@property (nonatomic, assign) BOOL isPresent;

-(NSString*)theTitleString;
-(NSString*)theUrlString;


@end

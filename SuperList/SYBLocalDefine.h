//
//

#ifndef SYBLocalDefine_h
#define SYBLocalDefine_h

#define kHost @""



/**
 * 字体大小使用
 */
#define FONT(i) [UIFont systemFontOfSize:i]
/**
 * 以下是项目中使用到的背景色
 */
#define mColor_TopTarBg @"#4286f5"
#define mColor_MainBg @"#f6f7f9"

/**
 * 限制只可以输入数字和字母
 */

#define TEXTFIELDKEYBOARDTYPE @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

/**
 * 系统参数设置
 */
#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf typeof(weakSelf) __strong strongSelf = weakSelf;

#define IS_IPHONE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define iPhone4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define iPhone5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define iPhone6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define iPhone6p (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height==2436 : NO)

#define KEYWINDOW [UIApplication sharedApplication].keyWindow

#define APPFRAME [UIScreen mainScreen].bounds
#define Main_Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Main_Screen_Height [UIScreen mainScreen].bounds.size.height
#define SDLRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#endif /* SYBLocalDefine_h */

//
//  NSString+X.m
//  NCENew
//
//  Created by palxex on 15/1/20.
//  Copyright (c) 2015年 cn.edu.ustc. All rights reserved.
//

#import "NSString+X.h"

@implementation NSString(X)

- (BOOL)validateWithPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *err = [NSString stringWithFormat:@"Unable to create regular expression with %@",pattern];
    NSAssert(regex, err);
    
    NSRange textRange = NSMakeRange(0, self.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:self options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = NO;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound)
        didValidate = YES;
    
    return didValidate;
}

- (NSString*)numCutted{
    NSArray *splitted = [self componentsSeparatedByString:@"."];
    if( splitted && splitted.count == 2 && ((NSString*)splitted[1]).length > 2 ) {
        return [NSString stringWithFormat:@"%@.%@",splitted[0],[splitted[1] substringToIndex:2]];
    }else {
        return self;
    }
}

- (NSString*)shortNum {
    NSString *s = self;
    double num = [s doubleValue];
    if( num >= 1000000000000 ) {
        s = [NSString stringWithFormat:@"%@万亿", [[@([[NSString stringWithFormat:@"%.2f",num/1000000000000] floatValue]) stringValue] numCutted]];
    }else if( num >= 100000000 ) {
        s = [NSString stringWithFormat:@"%@亿",  [[@([[NSString stringWithFormat:@"%.2f",num/100000000] floatValue]) stringValue] numCutted]];
    }else if( num >= 10000 ) {
        s = [NSString stringWithFormat:@"%@万",  [[@([[NSString stringWithFormat:@"%.2f",num/10000] floatValue]) stringValue] numCutted]];
    }else {
        s = [NSString stringWithFormat:@"%@",   [[@([[NSString stringWithFormat:@"%.2f",num] floatValue]) stringValue] numCutted]];
    }
    return s;
}

- (UIImage*)imageByAppendImage:(UIImage *)image{
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGSize expectedTextSize = [self sizeWithAttributes:@{NSFontAttributeName: font}];
    int width = expectedTextSize.width + image.size.width + 5;
    int height = MAX(expectedTextSize.height, image.size.width);
    CGSize size = CGSizeMake((float)width, (float)height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, color.CGColor);
    int fontTopPosition = (height - expectedTextSize.height) / 2;
    CGPoint textPoint = CGPointMake(0, fontTopPosition);
    
    [self drawAtPoint:textPoint withAttributes:@{NSFontAttributeName: font}];
    // Images upside down so flip them
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, (CGRect){ {expectedTextSize.width+5, (height - image.size.height) / 2}, {image.size.width, image.size.height} }, [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

#pragma mark format HTMLStr
//更改html样式
+(NSString *)webViewhtmlStr:(NSString *)htmlText
{
    float fontSize = 12;
    NSString *fontFamily = @"微软雅黑";
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %f; font-family: \"%@\";}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", fontSize, fontFamily, htmlText];
    return jsString;
}
@end

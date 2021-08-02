//
//  UIColor+TDHex.m
//  ToDo
//
//  Created by wyh on 2019/2/19.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "UIColor+TDHex.h"

@implementation UIColor (TDHex)

- (UIColor *)td_alpha:(CGFloat)alpha {
    return [self colorWithAlphaComponent:alpha];
}

/**
 *  根据6位16进制hex值获得颜色
 *
 *  @param hex 6位16进制hex值
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex {
    return [UIColor colorWithHexString:hex alpha:1.0f];
}


/**
 *  根据6位16进制hex值、透明度获得颜色
 *
 *  @param hex 6位16进制hex值
 *  @param alpha 透明度
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(float)alpha {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}


/**
 *  根据RGBA获得UIColor
 *
 *  @param rgbaString rgba(66,61,61,1)
 *
 *  @return color
 */
+ (UIColor *)colorWithRGBA:(NSString *)rgbaString {
    NSString *rgbaStr = [rgbaString stringByReplacingOccurrencesOfString:@"rgba(" withString:@""];
    rgbaStr = [rgbaStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray *rgbaStrValues = [rgbaStr componentsSeparatedByString:@","];
    
    UIColor *color = nil;
    if (rgbaStrValues.count >= 3) {
        float red = [[rgbaStrValues objectAtIndex:0] floatValue] / 255.0f;
        float green = [[rgbaStrValues objectAtIndex:1] floatValue] / 255.0f;
        float blue = [[rgbaStrValues objectAtIndex:2] floatValue] / 255.0f;
        
        if (rgbaStrValues.count == 4) {
            float alpha = [[rgbaStrValues objectAtIndex:3] floatValue];
            color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        } else {
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        }
    }
    
    return color;
}


#pragma mark - RandomColor
/**
 *  随机颜色
 *
 *  @return randomColor
 */
+ (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


@end

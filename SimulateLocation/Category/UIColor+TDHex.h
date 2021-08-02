//
//  UIColor+TDHex.h
//  ToDo
//
//  Created by wyh on 2019/2/19.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TDHex)

- (UIColor *)td_alpha:(CGFloat)alpha;

/**
 *  根据6位16进制hex值获得颜色
 *
 *  @param hex 6位16进制hex值
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex;


/**
 *  根据6位16进制hex值、透明度获得颜色
 *
 *  @param hex 6位16进制hex值
 *  @param alpha 透明度
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(float)alpha;


/**
 *  根据RGBA获得UIColor
 *
 *  @param rgbaString rgba(66,61,61,1)
 *
 *  @return color
 */
+ (UIColor *)colorWithRGBA:(NSString *)rgbaString;


#pragma mark - RandomColor
/**
 *  随机颜色
 *
 *  @return randomColor
 */
+ (UIColor *)randomColor;


@end

NS_ASSUME_NONNULL_END

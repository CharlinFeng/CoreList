//
//  UIImage+ShiDianRefreshTintColor.m
//  ShiDianRefresh
//
//  Created by 冯成林 on 16/10/10.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "UIImage+ShiDianRefresh.h"


@implementation UIImage (ShiDianRefreshTintColor)


- (UIImage *)tintColor:(UIColor *)tintColor{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}



-(UIImage *)remakeImageWithScale:(CGFloat)scale tintColor:(UIColor *)tintColor{
    
    CGSize fullSize = self.size;
    
    //新建上下文
    UIGraphicsBeginImageContextWithOptions(fullSize, NO, 0.0);

    [tintColor setFill];
    
    //图片原本size
    
    CGFloat sizeW = fullSize.width * scale;
    CGFloat sizeH = fullSize.height * scale;
    CGFloat x = (fullSize.width - sizeW) * 0.5f;
    CGFloat y = (fullSize.height - sizeH) * .5f;
    CGRect rect = CGRectMake(x, y, sizeW, sizeH);
    UIRectFill(rect);
    [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

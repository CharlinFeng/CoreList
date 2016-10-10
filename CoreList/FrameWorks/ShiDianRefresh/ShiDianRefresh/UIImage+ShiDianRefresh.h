//
//  UIImage+ShiDianRefreshTintColor.h
//  ShiDianRefresh
//
//  Created by 冯成林 on 16/10/10.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ShiDianRefresh)


- (UIImage *)tintColor:(UIColor *)tintColor;

-(UIImage *)remakeImageWithScale:(CGFloat)scale tintColor:(UIColor *)tintColor;

@end

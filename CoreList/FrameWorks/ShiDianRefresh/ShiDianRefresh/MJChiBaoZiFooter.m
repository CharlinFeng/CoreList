//
//  MJChiBaoZiFooter.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/6/12.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "MJChiBaoZiFooter.h"
#import "UIImage+ShiDianRefresh.h"


@implementation MJChiBaoZiFooter

#pragma mark - 重写方法
#pragma mark 基本设置

- (void)prepare{
    
    [super prepare];
    
    UIColor *c = [UIColor colorWithRed:0/255. green:122/255. blue:255/255. alpha:1];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=108; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ShiDianRefresh.bundle/dropdown_loading_0%zd", i]];
        image = [image tintColor:c];
        image = [image remakeImageWithScale:0.8 tintColor:c];
        [refreshingImages addObject:image];
    }
    
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
    
}


@end

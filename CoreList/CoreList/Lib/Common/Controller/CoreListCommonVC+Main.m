//
//  CoreListCommonVC+Main.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+Main.h"
#import "MJRefresh.h"

@implementation CoreListCommonVC (Main)



/** 刷新页面数据 */
-(void)refreshData{
    
    if(self.scrollView.mj_header.isRefreshing) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.scrollView.mj_footer removeFromSuperview];
        self.scrollView.mj_footer=nil;
        [self.scrollView.mj_header beginRefreshing];
        
    });
}




-(void)dealloc{
    [self.scrollView  removeFromSuperview];
    self.scrollView = nil;
}


@end

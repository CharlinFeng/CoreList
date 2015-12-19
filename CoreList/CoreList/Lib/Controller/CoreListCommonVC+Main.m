//
//  CoreListCommonVC+Main.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+Main.h"
#import "MJRefresh.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+BackBtn.h"
#import "CoreListCommonVC+Data.h"

@implementation CoreListCommonVC (Main)

/** 刷新页面数据 */
-(void)refreshData{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self dismissCustomView_EmptyView_ErrorView];
        
        [self.scrollView.mj_header endRefreshing];
        
        [self dismissBack2TopBtn];
        
        if(!self.shyNavBarOff) [self navBarShow];
        [self.scrollView.mj_footer removeFromSuperview];
        self.scrollView.mj_footer=nil;
        [self.scrollView.mj_header beginRefreshing];
    });
}



/** 默认值填充 */
-(ListVCRefreshAddType)listVC_RefreshType{return ListVCRefreshAddTypeBoth;}
-(BOOL)listVC_NeedBackBtn{return YES;}
-(UIView *)listVC_StatusView_Empty{return nil;}
-(UIView *)listVC_StatusView_Error{return nil;}




@end

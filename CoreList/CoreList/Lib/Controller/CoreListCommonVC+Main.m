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
-(void)refreshDataInMainThead:(BOOL)inMainThead{
 
    
    
    self.hasData = NO;
    self.needRefreshData = NO;
    if(!self.scrollView.mj_header.isRefreshing){
    
        if(inMainThead){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self back2Top];
                self.scrollView.userInteractionEnabled = NO;
                [self dismissCustomView_EmptyView_ErrorView];
                [self refreshData_Real];
            });
            
        }else{
        
            [self back2Top];
            self.scrollView.userInteractionEnabled = NO;
            [self dismissCustomView_EmptyView_ErrorView];
            [self refreshData_Real];
        }
        
    }else{
        
        if(inMainThead){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self back2Top];
                self.scrollView.userInteractionEnabled = NO;
                [self.scrollView.mj_header endRefreshing];
                [self dismissCustomView_EmptyView_ErrorView];
                [self performSelector:@selector(refreshData_Real) withObject:nil afterDelay:1];
            });

        }else{
            
            [self back2Top];
            self.scrollView.userInteractionEnabled = NO;
            [self.scrollView.mj_header endRefreshing];
            [self dismissCustomView_EmptyView_ErrorView];
            [self performSelector:@selector(refreshData_Real) withObject:nil afterDelay:1];
        }
    }
}


-(void)refreshData_Real{
    
    if(self.refreshType == ListVCRefreshAddTypeBoth || self.refreshType == ListVCRefreshAddTypeTopRefreshOnly) {if (self.scrollView.mj_header.isRefreshing) return;}
    
    if(self.scrollView.mj_header == nil){[self headerRefreshAdd];NSLog(@"安装");}
    [self dismissBack2TopBtn];
    if(!self.shyNavBarOff) [self navBarShow];
    [self.scrollView.mj_footer removeFromSuperview];
    self.scrollView.mj_footer=nil;
    [self.scrollView.mj_header beginRefreshing];
    self.scrollView.userInteractionEnabled = YES;
}



/** 默认值填充 */
-(ListVCRefreshAddType)listVC_RefreshType{return ListVCRefreshAddTypeBoth;}
-(BOOL)listVC_NeedBackBtn{return YES;}
-(UIView *)listVC_StatusView_Empty{return nil;}
-(UIView *)listVC_StatusView_Error{return nil;}




@end

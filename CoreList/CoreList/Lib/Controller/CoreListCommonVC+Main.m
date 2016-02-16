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
 
    self.needRefreshData = NO;

    BOOL isMainThread = [NSThread isMainThread];
    
    if(self.scrollView.mj_header.isRefreshing){
        
        if(!isMainThread){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self back2Top];
                self.scrollView.userInteractionEnabled = NO;
                [self.scrollView.mj_header endRefreshing];
                [CoreListMessageView dismissFromView:self.view];
                [self performSelector:@selector(refreshData_Prepare) withObject:nil afterDelay:1];
            });
            
        }else{
            
            [self back2Top];
            self.scrollView.userInteractionEnabled = NO;
            [self.scrollView.mj_header endRefreshing];
            
            [CoreListMessageView dismissFromView:self.view];
            [self performSelector:@selector(refreshData_Prepare) withObject:nil afterDelay:1];
        }

    }else{

        if(!isMainThread){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self back2Top];
                self.scrollView.userInteractionEnabled = NO;
                [CoreListMessageView dismissFromView:self.view];
                [self refreshData_Prepare];
            });
            
        }else{
            
            [self back2Top];
            self.scrollView.userInteractionEnabled = NO;
            
            [CoreListMessageView dismissFromView:self.view];
            [self refreshData_Prepare];
        }
    }
}


-(void)refreshData_Prepare{
    
    if(self.scrollView.contentOffset.y >= [UIScreen mainScreen].bounds.size.height){
    
        [self back2Top];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshData_Real];
        });
        
    }else {
    
        [self refreshData_Real];
    }

}

-(void)refreshData_Real{
    if(self.refreshType == ListVCRefreshAddTypeBoth || self.refreshType == ListVCRefreshAddTypeTopRefreshOnly) {if (self.scrollView.mj_header.isRefreshing) return;}
    
    if(self.scrollView.mj_header == nil){[self headerRefreshAdd];NSLog(@"安装");}
    [self dismissBack2TopBtn];
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

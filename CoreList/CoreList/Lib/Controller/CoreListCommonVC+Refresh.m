//
//  CoreListCommonVC+Refresh.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+Refresh.h"
#import "CoreListCommonVCProtocol.h"
#import "CoreModel.h"
#import "CoreListCommonVC+Data.h"
#import "NSArray+CoreListExtend.h"
#import "CoreStatus.h"
#import "CoreListVCNeedRefreshNotiModel.h"
#import "CoreListCommonVC+BackBtn.h"
#import "ShiDianRefreshHeader.h"

static NSString const *NoMoreDataMsg = @"没有更多数据了";

@implementation CoreListCommonVC (Refresh)

///** 自动触发顶部刷新 */
//-(void)triggerHeaderRefreshing{
//
//    [self.scrollView.mj_footer endRefreshingWithNoMoreData];
//
//    [self.scrollView.mj_footer removeFromSuperview];
//
//    self.scrollView.mj_footer = nil;
//
//    if(self.scrollView.mj_header == nil) {[self headerRefreshAdd];}
//
//    [self refreshData];
//}


/** 结束底部刷新 */
-(void)endFooterRefresWithMsg:(NSString *)msg{
    
    if(msg != nil) {
        
        [self.scrollView.mj_footer endRefreshingWithNoMoreData];
        
        [(MJRefreshAutoStateFooter *)self.scrollView.mj_footer setTitle:[NSString stringWithFormat:@"温馨提示：%@",msg] forState:MJRefreshStateNoMoreData];
        
    }else{
        
        [self removeFooterRefreshControl];
    }
}


/** 顶部刷新 */
-(void)headerRefreshAction{
    
    if(self.scrollView.isDragging) return;
    
    //    if(![CoreStatus isNETWORKEnable]) {[self.scrollView.mj_header endRefreshing]; return;};
    
    if(self.CoreListDidTrigerHeaderRefresh != nil){self.CoreListDidTrigerHeaderRefresh();}
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    
    [CoreListMessageView dismissFromView:self.view];
    
    [self removeFooterRefreshControl];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //标明刷新类型
    self.refreshType = ListVCRefreshActionTypeHeader;
    
    //页码复位
    self.page = [[self listVC_Model_Class] CoreModel_StartPage];
    
    //底部刷新控件复位
    [self.scrollView.mj_footer endRefreshing];
    
    //找模型要获取
    [self fetchDataFromModel];
    
    self.isRefreshData=YES;
    //    });
}





/** 底部刷新 */
-(void)footerRefreshAction{
    
    if(MJRefreshStateNoMoreData == self.scrollView.mj_footer.state) return;
    
    //标明刷新类型
    self.refreshType = ListVCRefreshActionTypeFooter;
    
    //页码增加
    self.page ++;
    
    //找模型要获取
    [self fetchDataFromModel];
}

/** 刷新成功：顶部 */
-(void)refreshSuccess4Header:(NSArray *)models{
    
    if([NSThread isMainThread]){
        [self.scrollView.mj_header endRefreshing];
        [self reloadData];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView.mj_header endRefreshing];
            [self reloadData];
        });
    }
    

    
    //存入数据
    self.dataList = models;
    
    
    self.isRefreshData=NO;
    
    if(![self.scrollView isKindOfClass:[UITableView class]]) return;
    if(!self.hasData) return;
    if(models.count==0) return;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self back2Top];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self back2Top];
//    });
//    
}


/** 刷新成功：底部 */
-(void)refreshSuccess4Footer:(NSArray *)models sourceType:(CoreModelDataSourceType)sourceType{
    
    NSUInteger count = models.count;
    
    NSUInteger pageSize = self.modelPageSize;
    
    NSArray *indexPaths = [NSArray indexPathsWithStartIndex:self.dataList.count count:count];
    
    //存入数据
    if(self.dataList == nil){//第一次没有数据
        
        //对nil无法发消息
        self.dataList = models;
        
    }else{
        
        self.dataList = [self.dataList appendArray:models];
    }
    
    if(models != nil && indexPaths != nil && self.dataList != nil){
        
        //刷新数据
        if ([NSThread isMainThread]) {
            
            //这里有个崩溃，先这样解决
            if(self.dataList.count <= self.modelPageSize){
                [self reloadData];return ;
            }
            /** 动态刷新 */
            [self reloadData];
            
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //这里有个崩溃，先这样解决
                if(self.dataList.count <= self.modelPageSize){
                    [self reloadData];return ;
                }
                /** 动态刷新 */
                [self reloadData];
            });
        }

    }
    
    UIEdgeInsets insets = self.originalScrollInsets;
    
    CGFloat finalInsetsBottom = MJRefreshFooterHeight;
    if(count < pageSize){//新的一页数据不足pagesize
        
        if(CoreModelDataSourceHostType_Sqlite_Nil == sourceType){
            
            //页码需要回退
            self.page -- ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endFooterRefresWithMsg:nil];
        });
        finalInsetsBottom = 0;
        if(self.tabBarController != nil  && !self.tabBarController.tabBar.hidden){finalInsetsBottom +=self.tabBarController.tabBar.bounds.size.height;}
        
    }else if (count >= pageSize){//有数据，满载
        
        if(self.tabBarController != nil  && !self.tabBarController.tabBar.hidden){finalInsetsBottom +=self.tabBarController.tabBar.bounds.size.height;}
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.scrollView.mj_footer endRefreshing];
        });
    }
    
    insets.bottom = finalInsetsBottom;
    
    if(!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.originalScrollInsets)){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollView.contentInset = insets;
        });
    }
}



/** 根据顶部刷新数据情况安装底部刷新控件 */
-(void)footerRefreshAdd:(NSArray *)models{
    
    [self footerRefreshAdd];
    
    NSUInteger count = models.count;
    
    if(count<=5){//不安装
        [self endFooterRefresWithMsg:nil];
        
    }else if (count >5 && count < self.modelPageSize){//安装，并将状态置为无数据
        
        [self endFooterRefresWithMsg:nil];
        
    }else if (count >= self.modelPageSize){//正常安装
        
        //        [self footerRefreshAdd];
    }
    
    self.hasFooter = YES;
}

/** 安装刷新控件：顶部刷新控件 */
-(void)headerRefreshAdd{
    
    //添加顶部刷新控件
    if(self.scrollView.mj_header == nil) {
        
        [self addHeader];
    }
}


/** 安装刷新控件：顶部刷新控件 */
-(void)footerRefreshAdd{
    
    if([NSThread isMainThread]){
        
        if(self.scrollView.mj_footer == nil) {
            
            [self addFooter];
        }
        
    }else{
        
        //添加底部刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addFooter];
        });
    }
}


-(void)addHeader{
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAction)];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    // 设置header
    self.scrollView.mj_header = header;
}


-(void)addFooter{
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)];
    
    // 隐藏状态
    footer.stateLabel.hidden = YES;
    
    // 隐藏刷新状态的文字
    footer.refreshingTitleHidden = YES;
    
    // 设置header
    self.scrollView.mj_footer = footer;
    
}



-(void)removeHeaderRefreshControl{
    
    [self.scrollView.mj_header endRefreshing];
    
    [self.scrollView.mj_header removeFromSuperview];
    self.scrollView.mj_header = nil;
}

-(void)removeFooterRefreshControl{
    
    [self.scrollView.mj_footer endRefreshing];
    [self.scrollView.mj_footer removeFromSuperview];
    self.scrollView.mj_footer = nil;
}



/*
 *  远程刷新方法
 */
+(void)needRefreshWithVCIndex:(NSInteger)vcIndex{
    
    CoreListVCNeedRefreshNotiModel *refreshModel = [CoreListVCNeedRefreshNotiModel quickNotiModel:[self class] vcIndex:vcIndex];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CoreListVCNeedRefreshDataNoti object:nil userInfo:@{CoreListVCNeedRefreshDataNoti:refreshModel}];
}

@end

//
//  CoreListCommonVC+Data.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+Data.h"
#import "CoreModel.h"
#import "MJRefresh.h"
#import "CoreModel+Cache.h"
#import "CoreListCommonVC+Refresh.h"
#import "CoreModelConst.h"
#import "UIView+CoreListLayout.h"
#import "CoreListCommonVC+Main.h"
#import "CoreListMessageView.h"
#import "CoreModel+CoreListCache.h"
#import "CoreListCommonVC+Task.h"

static NSString * const RefreshTypeKey = @"RefreshTypeKey";

@implementation CoreListCommonVC (Data)

/** 找模型要获取 */
-(void)fetchDataFromModel{
    
    if(ListVCRefreshActionTypeNone == self.refreshType) {
        
        NSLog(@"错误：刷新类型错误");
        
        return;
    }
    
    Class Model_Class = [self listVC_Model_Class];
    
    //当前页码信息：p,每页数据量信息：pageSize
    NSMutableDictionary *paramsM = [NSMutableDictionary dictionary];
    
    [paramsM addEntriesFromDictionary:@{[Model_Class CoreModel_PageKey] : @(self.page),[Model_Class CoreModel_PageSizeKey] : @([Model_Class CoreModel_PageSize])}];
    
    if ([self listVC_Request_Params] != nil) [paramsM addEntriesFromDictionary:[self listVC_Request_Params]];
    
    NSDictionary *userInfo = @{RefreshTypeKey : @(self.refreshType)};
    
    NSArray *ignoreParams = [self listVC_Ignore_Params];
    
    [Model_Class selectWithParams:paramsM ignoreParams:ignoreParams userInfo:userInfo beginBlock:^(BOOL isNetWorkRequest,BOOL needHUD,NSString *url, NSURLSessionDataTask *task){
        
        //记录task
        [self addTask:task forKey:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.hasFooter && isNetWorkRequest) [self.scrollView.mj_footer beginRefreshing];
        });
        
    } successBlock:^(NSArray *models, CoreModelDataSourceType sourceType,NSDictionary *userInfo){
      
        if(self.listVC_RefreshType == ListVCRefreshAddTypeBottomRefreshOnly){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeHeaderRefreshControl];
            });
        }
        
        ListVCRefreshActionType refreshType = [[userInfo objectForKey:RefreshTypeKey] integerValue];
        
        if(ListVCRefreshActionTypeHeader == refreshType){ //顶部数据刷新成功
            
            //刷新成功：顶部
            [self refreshSuccess4Header:models];
            
            if(sourceType != CoreModelDataSourceTypeSqlite){
                
                //处理指示视图状态
                [self handlestatusViewWithModels:models];
                
            }else {
            
                self.hasData = models.count > 0;
            }
            
            if(!self.hasData && models.count==0){
                [self handlestatusViewWithModels:models];
                
            }else{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //根据顶部刷新数据情况安装底部刷新控件
                    [self footerRefreshAdd:models];
                    if(self.scrollView.mj_footer == nil){[self refreshSuccess4Footer:models sourceType:CoreModelDataSourceTypeNone];}
                });
            }
        }
        
        if(ListVCRefreshActionTypeFooter == refreshType){ //底部数据刷新成功
            
            [self refreshSuccess4Footer:models sourceType:sourceType];
            
            // && CoreModelDataSourceTypeSqlite == sourceType
            if(models.count ==0){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endFooterRefresWithMsg:nil];
                });
                
            }
            
            //标明本地数据库没有数据了
            self.localDataNil = models.count ==0;
        }
        
        //标明刷新类型：这句一定要放在后面，因为在修改刷新状态为无之前，状态值还有用
        self.refreshType = ListVCRefreshActionTypeNone;
        
        //清除task
        [self removeTask];
        
    } errorBlock:^(NSString *errorResult,NSDictionary *userInfo) {

        //标记需要刷新
        self.needRefreshData = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView.mj_header endRefreshing];
        });
        
        if(self.hasData){
            
            if(!self.hasFooter) return;
            
            if(self.localDataNil){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endFooterRefresWithMsg:errorResult];
                });
            }
            
            //无缓存的情况
            if(!self.isNeedFMDB){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self endFooterRefresWithMsg:errorResult];
                });
                
                //页码回退
                self.page -- ;
            }
            
            //有缓存的情况
            if(ListVCRefreshActionTypeHeader != self.refreshType && self.localDataNil){
                //页码回退
                self.page -- ;
            }
            
        }else{
        
            //标明刷新类型
            self.refreshType = ListVCRefreshActionTypeNone;
            
            [self showErrorViewWithMsg:errorResult failClickBlock:^{
                
                [self refreshData];
            }];
        }
        
        //清除task
        [self removeTask];
        
    }];
}



-(void)showErrorViewWithMsg:(NSString *)msg failClickBlock:(void(^)())failClickBlock{
    
    if(self.hideStatusView) {return;}
    
    CGFloat topMargin = 0;
    
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self.scrollView;
        
        topMargin = tableView.tableHeaderView.bounds.size.height;
    }
    
    if([NSThread isMainThread]){
    
        [self.errorView showInView:self.view viewType:CoreListMessageViewTypeError topMargin:topMargin];
        
    }else{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.errorView showInView:self.view viewType:CoreListMessageViewTypeError topMargin:topMargin];
        });
    }
}



-(void)handlestatusViewWithModels:(NSArray *)models{
    
    CGFloat topMargin = 0;
    
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self.scrollView;
        
        topMargin = tableView.tableHeaderView.bounds.size.height;
    }
    
    if([NSThread isMainThread]){
        
        NSUInteger count = models.count;
        
        BOOL noData = models == nil || count == 0;
        
        if(noData && !self.hideStatusView){//没有数据
            
            //标记需要刷新
            self.needRefreshData = YES;
            
            [self.emptyView showInView:self.view viewType:CoreListMessageViewTypeEmpty topMargin:topMargin];
            
        }else{//有数据，隐藏
            
            [CoreListMessageView dismissFromView:self.view];
            
            self.hasData = YES;
        }

    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSUInteger count = models.count;
            
            BOOL noData = models == nil || count == 0;
            
            if(noData && !self.hideStatusView){//没有数据
                
                //标记需要刷新
                self.needRefreshData = YES;
                
                [self.emptyView showInView:self.view viewType:CoreListMessageViewTypeEmpty topMargin:topMargin];
                
            }else{//有数据，隐藏
                
                [CoreListMessageView dismissFromView:self.view];
                
                self.hasData = YES;
            }
        });
    }
}




-(BOOL)isNeedFMDB{
    
    return [[self listVC_Model_Class] CoreModel_NeedFMDB];
}

@end

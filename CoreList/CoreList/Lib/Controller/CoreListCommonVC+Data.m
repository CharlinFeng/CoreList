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
#import "CoreIV.h"
#import "CoreModel+Cache.h"
#import "CoreListCommonVC+Refresh.h"
#import "CoreIV.h"
#import "CoreModelConst.h"
#import "UIView+CoreListLayout.h"

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
    
    [Model_Class selectWithParams:paramsM ignoreParams:ignoreParams userInfo:userInfo beginBlock:^(BOOL isNetWorkRequest,BOOL needHUD){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.hasFooter && isNetWorkRequest) [self.scrollView.mj_footer beginRefreshing];
        });
        
    } successBlock:^(NSArray *models, CoreModelDataSourceType sourceType,NSDictionary *userInfo){
        
        if(self.listVC_RefreshType == ListVCRefreshAddTypeBottomRefreshOnly){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeHeaderRefreshControl];
            });
        }
        
        [CoreIV dismissFromView:self.view animated:YES];
        
        ListVCRefreshActionType refreshType = [[userInfo objectForKey:RefreshTypeKey] integerValue];
        
        if(ListVCRefreshActionTypeHeader == refreshType){ //顶部数据刷新成功
            
            //刷新成功：顶部
            [self refreshSuccess4Header:models];
            
            if(sourceType != CoreModelDataSourceTypeSqlite){
                
                //处理指示视图状态
                [self handlestatusViewWithModels:models];
            }
            
            if(!self.hasData && models.count==0 && !self.needOffCoreIVWhenNoData){
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
                    [self endFooterRefresWithMsg:@"没有更多数据了"];
                });
                
            }
            
            //标明本地数据库没有数据了
            self.localDataNil = models.count ==0;
        }
        
        
        //标明刷新类型：这句一定要放在后面，因为在修改刷新状态为无之前，状态值还有用
        self.refreshType = ListVCRefreshActionTypeNone;
        
    } errorBlock:^(NSString *errorResult,NSDictionary *userInfo) {
        
        
        if(errorResult != nil && ![errorResult isEqualToString:NetWorkError]){ //网络请求成功，但服务器抛出错误
            
            __weak typeof(self) weakSelf=self;
            
            [CoreIV dismissFromView:self.view animated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self showErrorViewWithMsg:@"加载失败，点击重试" failClickBlock:^{

                    if(weakSelf.NetWorkErrorAction != nil) weakSelf.NetWorkErrorAction();
                    
                    [CoreIV showWithType:IVTypeLoad view:self.view msg:@"努力加载中" failClickBlock:nil];
                    
                    [self refreshData];
                }];
            });
            
            return;
        }
        
        
        if(self.hasData){
            
            
            if(!self.hasFooter) return;
            
            if(self.localDataNil){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self endFooterRefresWithMsg:@"数据加载失败"];
                });
            }
            
            //无缓存的情况
            if(!self.isNeedFMDB){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self endFooterRefresWithMsg:@"数据加载失败"];
                });
                
                //页码回退
                self.page -- ;
            }
            
            //有缓存的情况
            if(ListVCRefreshActionTypeHeader != self.refreshType && self.localDataNil){
                //页码回退
                self.page -- ;
            }
            
            
            return;
        }
        
        //标明刷新类型
        self.refreshType = ListVCRefreshActionTypeNone;
        
        [self showErrorViewWithMsg:@"加载失败，点击重试" failClickBlock:^{

            [CoreIV showWithType:IVTypeLoad view:self.view msg:@"努力加载中" failClickBlock:nil];
            [self refreshData];
        }];
    }];
}





-(void)showErrorViewWithMsg:(NSString *)msg failClickBlock:(void(^)())failClickBlock{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *errorView = [self listVC_StatusView_Error];
        
        self.errorView = errorView;
        
        if (errorView == nil) {
            
            [CoreIV showWithType:IVTypeError view:self.view msg:msg failClickBlock:failClickBlock];
            
        }else{
            
            [self.view addSubview:errorView];
            
            [errorView autoLayoutFillSuperView];
        }
    });
}



-(void)handlestatusViewWithModels:(NSArray *)models{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger count = models.count;
        
        BOOL noData = models == nil || count == 0;

        UIView *emptyView = [self listVC_StatusView_Empty];
        
        self.emptyView = emptyView;
        
        if(noData){//没有数据
            
            if (self.needOffCoreIVWhenNoData) return;
            
            if (emptyView == nil) {
                
                [CoreIV showWithType:IVTypeError view:self.view msg:@"没有更多数据了" failClickBlock:nil];
                
            }else{
                
                [self.view addSubview:emptyView];
                
                [emptyView autoLayoutFillSuperView];
            
            }
            
        }else{//有数据，隐藏
            
            [CoreIV dismissFromView:self.view animated:YES];
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.emptyView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                [self.emptyView removeFromSuperview];
                
            }];
            
            self.hasData = YES;
        }
        
    });
}


-(void)dismissCustomView_EmptyView_ErrorView{

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            
            self.emptyView.alpha = 0;
            self.errorView.alpha = 0;
        } completion:^(BOOL finished) {
            
            [self.emptyView removeFromSuperview];
            [self.errorView removeFromSuperview];
        }];
    });
}


-(BOOL)isNeedFMDB{
    
    return [[self listVC_Model_Class] CoreModel_NeedFMDB];
}

@end

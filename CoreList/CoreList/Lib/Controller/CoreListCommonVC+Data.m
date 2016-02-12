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
        
        ListVCRefreshActionType refreshType = [[userInfo objectForKey:RefreshTypeKey] integerValue];
        
        if(ListVCRefreshActionTypeHeader == refreshType){ //顶部数据刷新成功
            
            //刷新成功：顶部
            [self refreshSuccess4Header:models];
            
            if(sourceType != CoreModelDataSourceTypeSqlite){
                
                //处理指示视图状态
                [self handlestatusViewWithModels:models];
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
                
                [self refreshDataInMainThead:NO];
            }];
        }

    }];
}





-(void)showErrorViewWithMsg:(NSString *)msg failClickBlock:(void(^)())failClickBlock{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        id errorObj = [self listVC_StatusView_Error];

        UIView *errorView =nil;
        
        if (errorObj == nil){
            
            errorView = self.errorView;
            
        }else{
            
            if([errorObj isKindOfClass:[UIView class]]){
            
                errorView = errorObj;
                
            }else{
                
                NSArray *array = (NSArray *)errorObj;
                CoreListMessageView *errorView_defalt = (CoreListMessageView *)self.errorView;
                errorView = errorView_defalt;
                [errorView_defalt update:array[0] desc:array[1] constant:[array[2] floatValue]];
            }
        }
        
        [self.errorView showInView:self.view viewType:CoreListMessageViewTypeError needMainTread:NO];
        
    });
}



-(void)handlestatusViewWithModels:(NSArray *)models{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger count = models.count;
        
        BOOL noData = models == nil || count == 0;
     
        if(noData){//没有数据
            
            //标记需要刷新
            self.needRefreshData = YES;
            
            id emptyObj = [self listVC_StatusView_Empty];
            
            UIView *emptyView = nil;
            
            if(emptyObj == nil){
                
                emptyView = self.emptyView;
                
            }else {
                
                if([emptyObj isKindOfClass:[UIView class]]){
                
                    emptyView = (UIView *)emptyObj;
                    
                }else {
                
                    NSArray *array = (NSArray *)emptyObj;
                    CoreListMessageView *emptyView_default = (CoreListMessageView *)self.emptyView;
                    emptyView = emptyView_default;
                    [emptyView_default update:array[0] desc:array[1] constant:[array[2] floatValue]];
                }
            
            }
            [self.emptyView showInView:self.view viewType:CoreListMessageViewTypeEmpty needMainTread:NO];

            
            
            
        }else{//有数据，隐藏
            
            [self.emptyView dismiss:YES needMainTread:NO];

            self.hasData = YES;
        }
        
    });
}




-(BOOL)isNeedFMDB{
    
    return [[self listVC_Model_Class] CoreModel_NeedFMDB];
}

@end

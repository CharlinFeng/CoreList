//
//  CoreListCommonVC+Refresh.h
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "CoreModelType.h"

@interface CoreListCommonVC (Refresh)


///** 自动触发顶部刷新 */
//-(void)triggerHeaderRefreshing;

/** 结束底部刷新 */
-(void)endFooterRefresWithMsg:(NSString *)msg;


/** 顶部刷新 */
-(void)headerRefreshAction;


/** 底部刷新 */
-(void)footerRefreshAction;



/** 刷新成功：顶部 */
-(void)refreshSuccess4Header:(NSArray *)models;

/** 刷新成功：底部 */
-(void)refreshSuccess4Footer:(NSArray *)models sourceType:(CoreModelDataSourceType)sourceType;

/** 根据顶部刷新数据情况安装底部刷新控件 */
-(void)footerRefreshAdd:(NSArray *)models;


-(void)removeHeaderRefreshControl;
-(void)removeFooterRefreshControl;

@end

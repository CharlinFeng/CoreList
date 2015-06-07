//
//  CoreListType.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#ifndef CoreList_CoreListType_h
#define CoreList_CoreListType_h


/** 刷新控件安装方式 */

typedef enum{
    
    //顶部刷新、底部刷新控件均安装
    ListVCRefreshAddTypeBoth=0,
    
    //仅仅安装顶部刷新新控
    ListVCRefreshAddTypeTopRefreshOnly,
    
    //仅仅安装底部刷新新控
    ListVCRefreshAddTypeBottomRefreshOnly,
    
    //顶部刷新、底部刷新控件均不安装，仅仅是利用数据解析的便利
    ListVCRefreshAddTypeNeither,
    
    
}ListVCRefreshAddType;






/** 刷新类型 */

typedef enum{

    //目前没有刷新
    ListVCRefreshActionTypeNone = 0,
    
    //顶部刷新
    ListVCRefreshActionTypeHeader,
    
    //底部刷新
    ListVCRefreshActionTypeFooter
    
}ListVCRefreshActionType;











#endif

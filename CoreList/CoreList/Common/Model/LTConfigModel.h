//
//  CoreLTVCConfigModel.h
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-9.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//  配置模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    
    //GET
    LTConfigModelHTTPMethodGET=0,
    
    //POST
    LTConfigModelHTTPMethodPOST,
    
}LTConfigModelHTTPMethod;



typedef enum{
    
    //顶部刷新、底部刷新控件均安装
    LTConfigModelRefreshControlTypeBoth=0,
    
    //仅仅安装顶部刷新新控
    LTConfigModelRefreshControlTypeTopRefreshOnly,
    
    //仅仅安装底部刷新新控
    LTConfigModelRefreshControlTypeBottomRefreshOnly,
    
    //顶部刷新、底部刷新控件均不安装，仅仅是利用数据解析的便利
    LTConfigModelRefreshControlTypeNeither,
    
    
}LTConfigModelRefreshControlType;



@interface LTConfigModel : NSObject


/**
 *  ----------------必传参数----------------url、params、ModelClass、ViewForCellClass
 */






/**
 *  数据模型类
 */
@property (nonatomic,assign) Class ModelClass;


/**
 *  cell所用类:注，cell默认从xib创建
 */
@property (nonatomic,assign) Class ViewForCellClass;








/**
 *  刷新控件安装方式:默认为均安装
 */
@property (nonatomic,assign) LTConfigModelRefreshControlType refreshControlType;



/**
 *  是否移除返回顶部功能按钮，默认不移除
 */
@property (nonatomic,assign) BOOL removeBackToTopBtn;


@end

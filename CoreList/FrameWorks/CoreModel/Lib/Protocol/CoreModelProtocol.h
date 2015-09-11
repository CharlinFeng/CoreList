//
//  CoreModelProtocol.h
//  CoreClass
//
//  Created by 冯成林 on 15/5/28.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreModelType.h"






@protocol CoreModelProtocol <NSObject>

@required


/** 接口地址 */
+(NSString *)CoreModel_UrlString;

/** 请求方式 */
+(CoreModelHttpType)CoreModel_HttpType;

/** 是否需要本地缓存 */
+(BOOL)CoreModel_NeedFMDB;

/** 缓存周期：单位秒 */
+(NSTimeInterval)CoreModel_Duration;


/**
 *  错误数据解析：请求成功，但服务器返回的接口状态码抛出错误
 *
 *  @param hostData 服务器数据
 *
 *  @return 如果为nil，表示无错误；如果不为空表示有错误，并且为错误信息。
 */
+(NSString *)CoreModel_parseErrorData:(id)hostData;


/** 服务器真正有用数据体：此时只是找到对应的key，还没有字典转模型 */
+(id)CoreModel_findUsefullData:(id)hostData;


/** 返回数据格式 */
+(CoreModelHostDataType)CoreModel_hostDataType;








@end

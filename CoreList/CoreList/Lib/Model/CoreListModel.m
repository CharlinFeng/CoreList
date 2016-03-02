//
//  CoreListModel.m
//  Home
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "CoreListModel.h"

@implementation CoreListModel

/*
 *  协议方法区
 */

/** 接口地址 */
+(NSString *)CoreModel_UrlString{
    return @"";
}

/** 请求方式 */
+(CoreModelHttpType)CoreModel_HttpType{
    return CoreModelHttpTypePOST;
}

/** 是否需要本地缓存 */
+(BOOL)CoreModel_NeedFMDB{
    return NO;
}

/** 缓存周期：单位秒 */
+(NSTimeInterval)CoreModel_Duration{
    return 60 * 60;
}


/**
 *  错误数据解析：请求成功，但服务器返回的接口状态码抛出错误
 *
 *  @param hostData 服务器数据
 *
 *  @return 如果为nil，表示无错误；如果不为空表示有错误，并且为错误信息。
 */
+(NSString *)CoreModel_parseErrorData:(NSDictionary *)hostData{
    
    NSString *msgOut = hostData[@"msg"];
    
    if(![msgOut isEqualToString:@"ok"]) {
    
        NSInteger status = [hostData[@"status"] integerValue];
        if(status == 900){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AppHttpTokenDeprecatedNoti" object:nil userInfo:nil];
            });
            
            NSLog(@"错误：Token过期");
            
            msgOut = @"请重新登陆";
        }
        return msgOut;
    }
    
    NSString *msgIn = hostData[@"res"][@"res_msg"];
    if(![msgIn isEqualToString:@"ok"]) return msgIn;
    
    return nil;
}

/** 服务器真正有用数据体：此时只是找到对应的key，还没有字典转模型 */
+(id)CoreModel_findUsefullData:(NSDictionary *)hostData{
    return hostData[@"res"][@"res_data"];
}





/** 返回数据格式 */
+(CoreModelHostDataType)CoreModel_hostDataType{
    return CoreModelHostDataTypeModelArray;
}

/**
 *  是否为分页数据
 *
 *  @return 如果为分页模型请返回YES，否则返回NO
 */
+(BOOL)CoreModel_isPageEnable{
    return YES;
}


/** page字段 */
+(NSString *)CoreModel_PageKey{
    return @"page";
}


/** pagesize字段 */
+(NSString *)CoreModel_PageSizeKey{
    return @"pagesize";
}


/** 页码起点 */
+(NSUInteger)CoreModel_StartPage{
    return 1;
}


/** 每页数据量 */
+(NSUInteger)CoreModel_PageSize{
    return 36;
}


@end

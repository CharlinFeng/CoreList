//
//  TGModel.m
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "TGModel.h"
#import "NSObject+MJKeyValue.h"

@implementation TGModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellH = 80 + arc4random_uniform(70);
    }
    return self;
}






/*
 *  协议方法区
 */


/** 接口地址 */
+(NSString *)CoreModel_UrlString{
    return @"http://211.149.151.92/Carpenter/Test/Info/testdata";
}

/** 请求方式 */
+(CoreModelHttpType)CoreModel_HttpType{
    return CoreModelHttpTypePOST;
}

/** 是否需要本地缓存 */
+(BOOL)CoreModel_NeedFMDB{
    return YES;
}

/** 缓存周期：单位秒 */
+(NSTimeInterval)CoreModel_Duration{
    return 1;
}

/**
 *  错误数据解析：请求成功，但服务器返回的接口状态码抛出错误
 *
 *  @param hostData 服务器数据
 *
 *  @return 如果为nil，表示无错误；如果不为空表示有错误，并且为错误信息。
 */
+(NSString *)CoreModel_parseErrorData:(id)hostData{
    
    NSString *errorResult = nil;
    
    if([hostData[@"status"] integerValue] != 100) errorResult = hostData[@"msg"];
    
    return errorResult;
}

/** 服务器真正有用数据体：此时只是找到对应的key，还没有字典转模型 */
+(id)CoreModel_findUsefullData:(id)hostData{
    return hostData[@"data"];
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
    return @"p";
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
    return 18;
}


@end
